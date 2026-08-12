module Workspace
  class MembershipsController < ApplicationController
    before_action :require_agency_admin!

    def create
      User.transaction do
        user = User.find_or_initialize_by(email_address: params.dig(:membership, :email_address).to_s.strip.downcase)
        if user.new_record?
          user.assign_attributes(name: params.dig(:membership, :name), password: params.dig(:membership, :password))
          user.save!
        end
        membership = current_tenant.memberships.new(user:, location_id: membership_location_id)
        membership.role = membership_role
        membership.save!
      end
      redirect_to workspace_path, notice: "Member added."
    rescue ActiveRecord::RecordInvalid => error
      redirect_to workspace_path, alert: error.record.errors.full_messages.to_sentence
    end

    private

    def membership_location_id
      params.require(:membership).permit(:location_id)[:location_id].presence
    end

    def membership_role
      role = params.require(:membership).fetch(:role).to_s
      return role if Membership.roles.key?(role)

      raise ActionController::BadRequest, "Unknown membership role"
    end
  end
end
