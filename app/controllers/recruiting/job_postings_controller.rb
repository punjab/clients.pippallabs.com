module Recruiting
  class JobPostingsController < ApplicationController
    before_action :require_recruiting_manager!

    def create
      current_tenant.job_postings.create!(job_posting_params)
      redirect_to recruiting_path, notice: "Position published."
    rescue ActiveRecord::RecordInvalid => error
      redirect_to recruiting_path, alert: error.record.errors.full_messages.to_sentence
    end

    def update
      position = current_tenant.job_postings.find(params[:id])
      status = params[:status].to_s
      raise ActionController::BadRequest, "Unknown position status" unless JobPosting.statuses.key?(status)

      position.update!(status:)
      redirect_to recruiting_path, notice: "Position #{status}."
    end

    private

    def job_posting_params
      params.require(:job_posting).permit(:title, :key, :location_id, :description)
    end

    def require_recruiting_manager!
      return if current_tenant.feature_enabled?(:recruiting) && can_manage_recruiting?

      redirect_to root_path, alert: "Recruiting manager access is required."
    end
  end
end
