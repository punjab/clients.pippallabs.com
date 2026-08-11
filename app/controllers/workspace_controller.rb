class WorkspaceController < ApplicationController
  before_action :require_agency_admin!

  def show
    @locations = current_tenant.locations.order(:name)
    @websites = current_tenant.websites.order(:name)
    @memberships = current_tenant.memberships.includes(:user, :location).order(:role)
  end

  private

  def require_agency_admin!
    redirect_to root_path, alert: "Agency admin access is required." unless current_membership.agency_admin?
  end
end
