class WorkspaceController < ApplicationController
  before_action :require_agency_admin!

  def show
    @locations = current_tenant.locations.order(:name)
    @websites = current_tenant.websites.order(:name)
    @memberships = current_tenant.memberships.includes(:user, :location).order(:role)
  end
end
