module Workspace
  class LocationsController < ApplicationController
    before_action :require_agency_admin!

    def create
      location = current_tenant.locations.create!(location_params)
      redirect_to workspace_path, notice: "#{location.name} was added."
    rescue ActiveRecord::RecordInvalid => error
      redirect_to workspace_path, alert: error.record.errors.full_messages.to_sentence
    end

    private

    def location_params
      params.require(:location).permit(:name, :key, :alert_email)
    end

    def require_agency_admin!
      redirect_to root_path, alert: "Agency admin access is required." unless current_membership.agency_admin?
    end
  end
end
