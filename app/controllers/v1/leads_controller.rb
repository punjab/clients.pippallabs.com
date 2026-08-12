module V1
  class LeadsController < BaseController
    allow_unauthenticated_access only: :create
    skip_forgery_protection only: :create
    before_action :reject_oversized_payload, only: :create
    before_action :require_lead_manager!, only: %i[update notes reopen]
    before_action :set_lead, only: %i[show update notes reopen]

    rate_limit to: 60, within: 1.minute, only: :create, by: -> { request.remote_ip }, with: -> { render json: { error: "rate_limited" }, status: :too_many_requests }

    def create
      website = Website.authenticate_key(params[:tracking_key])
      return render json: { error: "invalid_tracking_key", request_id: request.request_id }, status: :unauthorized unless website

      result = LeadIngestor.call(website:, attributes: lead_create_params.to_h.symbolize_keys, request_id: request.request_id)
      render json: { accepted: true, lead_id: result.lead.id, duplicate: result.duplicate },
        status: result.duplicate ? :ok : :created
    rescue ActiveRecord::RecordInvalid => error
      render_validation_error(error.record)
    rescue ContactResolver::IdentityConflict => error
      render json: { error: "identity_conflict", details: error.message, request_id: request.request_id }, status: :unprocessable_entity
    end

    def index
      leads = scoped_leads.includes(:contact, :location, :owner).order(created_at: :desc)
      leads = leads.where(status: params[:status]) if params[:status].present? && Lead.statuses.key?(params[:status])
      leads = leads.where(lead_type: params[:type]) if params[:type].present?
      leads = leads.where(location_id: params[:location_id]) if params[:location_id].present?
      leads = leads.where(owner_id: params[:owner_id]) if params[:owner_id].present?
      leads = apply_follow_up_filter(leads)
      render json: { leads: leads.limit(100).map { |lead| lead_json(lead) }, count: leads.count }
    end

    def show
      render json: lead_detail_json(@lead)
    end

    def update
      LeadWorkflow.update(lead: @lead, actor: current_user, membership: current_membership, attributes: lead_update_params)
      render json: lead_detail_json(@lead.reload)
    rescue LeadWorkflow::InvalidTransition, ActiveRecord::RecordInvalid => error
      render json: { error: "invalid_workflow_change", details: error.message }, status: :unprocessable_entity
    end

    def notes
      LeadWorkflow.add_note(lead: @lead, actor: current_user, membership: current_membership, note: params[:note])
      render json: lead_detail_json(@lead.reload), status: :created
    rescue ActiveRecord::RecordInvalid => error
      render json: { error: "invalid_note", details: error.message }, status: :unprocessable_entity
    end

    def reopen
      LeadWorkflow.reopen(lead: @lead, actor: current_user, membership: current_membership)
      render json: lead_detail_json(@lead.reload)
    rescue LeadWorkflow::InvalidTransition => error
      render json: { error: "invalid_workflow_change", details: error.message }, status: :unprocessable_entity
    end

    private

    def scoped_leads
      scope = current_tenant.leads
      location_scoped? ? scope.where(location_id: current_membership.location_id) : scope
    end

    def set_lead
      @lead = scoped_leads.find(params[:id])
    end

    def lead_create_params
      params.permit(
        :idempotency_key, :lead_type, :occurred_at, :name, :email, :phone,
        :message, :location_key, :source, :page_url, :utm_source, :utm_medium,
        :utm_campaign, :estimated_value, :email_consent, :sms_consent,
        :consent_source, :consent_timestamp
      )
    end

    def lead_update_params
      params.permit(:status, :owner_id, :location_id, :follow_up_at, :estimated_value, :actual_value, :lost_reason)
    end

    def reject_oversized_payload
      render json: { error: "payload_too_large", request_id: request.request_id }, status: :payload_too_large if request.content_length.to_i > 64.kilobytes
    end

    def render_validation_error(record)
      render json: { error: "invalid_payload", details: record.errors.to_hash, request_id: request.request_id }, status: :unprocessable_entity
    end

    def apply_follow_up_filter(scope)
      case params[:follow_up]
      when "overdue" then scope.merge(Lead.overdue)
      when "upcoming" then scope.active.where(follow_up_at: Time.current..)
      when "unset" then scope.active.where(follow_up_at: nil)
      else scope
      end
    end

    def lead_json(lead)
      {
        id: lead.id,
        status: lead.status,
        lead_type: lead.lead_type,
        occurred_at: lead.occurred_at,
        follow_up_at: lead.follow_up_at,
        estimated_value: lead.estimated_value,
        actual_value: lead.actual_value,
        source: lead.source,
        contact: { id: lead.contact.id, name: lead.contact.name, email: lead.contact.email, phone: lead.contact.phone },
        location: lead.location && { id: lead.location.id, name: lead.location.name },
        owner: lead.owner && { id: lead.owner.id, name: lead.owner.name }
      }
    end

    def lead_detail_json(lead)
      {
        lead: lead_json(lead).merge(message: lead.message, page_url: lead.page_url, lost_reason: lead.lost_reason),
        history: lead.histories.includes(:actor).order(occurred_at: :desc).map do |entry|
          {
            id: entry.id,
            change_type: entry.change_type,
            from_status: entry.from_status,
            to_status: entry.to_status,
            note: entry.note,
            changeset: entry.changeset,
            actor: entry.actor && { id: entry.actor.id, name: entry.actor.name },
            occurred_at: entry.occurred_at
          }
        end
      }
    end
  end
end
