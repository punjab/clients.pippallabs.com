module Agency
  class TenantsController < ApplicationController
    before_action :require_agency_admin!

    def index
      @memberships = current_user.memberships.joins(:tenant).includes(:tenant).order("tenants.name")
    end

    def create
      tenant = Tenant.transaction do
        created = Tenant.create!(tenant_params)
        location = created.locations.create!(name: params[:location_name], key: params[:location_key], alert_email: params[:alert_email])
        website = created.websites.create!(name: "Main website", allowed_domain: params[:allowed_domain], fallback_location: location)
        created.memberships.create!(user: current_user, role: :agency_admin)
        flash[:notice] = "Workspace created. Copy the tracking key now: #{website.tracking_key}"
        created
      end
      membership = current_user.memberships.find_by!(tenant:)
      Current.session.update!(membership:)
      redirect_to workspace_path
    rescue ActiveRecord::RecordInvalid => error
      redirect_to agency_tenants_path, alert: error.record.errors.full_messages.to_sentence
    end

    private

    def tenant_params
      params.permit(:name, :slug, :time_zone, :notification_email)
    end

    def require_agency_admin!
      redirect_to root_path, alert: "Agency admin access is required." unless current_membership.agency_admin?
    end
  end
end
