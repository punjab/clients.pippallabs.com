module Workspace
  class WebsitesController < ApplicationController
    before_action :require_agency_admin!

    def create
      website = current_tenant.websites.create!(website_params)
      redirect_to workspace_path, notice: "Website added. Copy this tracking key now: #{website.tracking_key}"
    rescue ActiveRecord::RecordInvalid => error
      redirect_to workspace_path, alert: error.record.errors.full_messages.to_sentence
    end

    def rotate
      website = current_tenant.websites.find(params[:id])
      website.tracking_key = "pk_#{SecureRandom.urlsafe_base64(24)}"
      website.save!
      redirect_to workspace_path, notice: "Key rotated. Copy it now: #{website.tracking_key}"
    end

    private

    def website_params
      params.require(:website).permit(:name, :allowed_domain, :fallback_location_id)
    end

    def require_agency_admin!
      redirect_to root_path, alert: "Agency admin access is required." unless current_membership.agency_admin?
    end
  end
end
