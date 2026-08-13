class LeadsController < ApplicationController
  before_action :set_lead, only: %i[show update note reopen]
  before_action :require_manager!, only: %i[update note reopen]

  def index
    @locations = accessible_locations.active.order(:name)
    @members = current_tenant.memberships.includes(:user).where(role: %i[agency_admin client_owner location_manager])
    @leads = filtered_leads.includes(:contact, :location, :owner).order(created_at: :desc).limit(100)
    @counts = scoped_leads.group(:status).count.transform_keys { |key| Lead.statuses.key(key) }
  end

  def show
    @members = current_tenant.memberships.includes(:user).where(role: %i[agency_admin client_owner location_manager])
    @locations = accessible_locations.active.order(:name)
    @history = @lead.histories.includes(:actor).order(occurred_at: :desc)
  end

  def update
    LeadWorkflow.update(lead: @lead, actor: current_user, membership: current_membership, attributes: lead_params)
    redirect_to lead_path(@lead), notice: "Lead updated."
  rescue LeadWorkflow::InvalidTransition, ActiveRecord::RecordInvalid => error
    redirect_to lead_path(@lead), alert: error.message
  end

  def note
    LeadWorkflow.add_note(lead: @lead, actor: current_user, membership: current_membership, note: params[:note])
    redirect_to lead_path(@lead), notice: "Note added."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to lead_path(@lead), alert: error.message
  end

  def reopen
    LeadWorkflow.reopen(lead: @lead, actor: current_user, membership: current_membership)
    redirect_to lead_path(@lead), notice: "Lead reopened."
  rescue LeadWorkflow::InvalidTransition => error
    redirect_to lead_path(@lead), alert: error.message
  end

  private

  def scoped_leads
    scope = current_tenant.leads.non_newsletter
    location_scoped? ? scope.where(location_id: current_membership.location_id) : scope
  end

  def filtered_leads
    scope = scoped_leads
    scope = scope.where(status: params[:status]) if params[:status].present? && Lead.statuses.key?(params[:status])
    scope = scope.where(lead_type: params[:type]) if params[:type].present?
    scope = scope.where(location_id: params[:location_id]) if params[:location_id].present?
    scope = scope.where(owner_id: params[:owner_id]) if params[:owner_id].present?
    scope = scope.where("contacts.name ILIKE :query OR contacts.email ILIKE :query", query: "%#{ActiveRecord::Base.sanitize_sql_like(params[:q])}%").joins(:contact) if params[:q].present?
    case params[:follow_up]
    when "overdue" then scope.merge(Lead.overdue)
    when "upcoming" then scope.active.where(follow_up_at: Time.current..)
    when "unset" then scope.active.where(follow_up_at: nil)
    else scope
    end
  end

  def set_lead
    @lead = scoped_leads.find(params[:id])
  end

  def require_manager!
    redirect_to lead_path(@lead), alert: "You have view-only access." unless can_manage_leads?
  end

  def lead_params
    params.require(:lead).permit(:status, :owner_id, :location_id, :follow_up_at, :estimated_value, :actual_value, :lost_reason)
  end
end
