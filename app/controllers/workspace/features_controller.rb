module Workspace
  class FeaturesController < ApplicationController
    before_action :require_agency_admin!

    def update
      feature = current_tenant.workspace_features.find_or_initialize_by(key: params[:id])
      feature.update!(enabled: ActiveModel::Type::Boolean.new.cast(params[:enabled]))
      redirect_to workspace_path, notice: "#{feature.key.humanize} #{feature.enabled? ? 'enabled' : 'disabled'}."
    rescue ActiveRecord::RecordInvalid => error
      redirect_to workspace_path, alert: error.record.errors.full_messages.to_sentence
    end

    private

    def require_agency_admin!
      redirect_to root_path, alert: "Agency admin access is required." unless current_membership.agency_admin?
    end
  end
end
