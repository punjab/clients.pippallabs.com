module Recruiting
  class JobApplicationsController < ApplicationController
    before_action :require_recruiting_access!
    before_action :set_application

    def show
      @history = @application.histories.includes(:actor).order(occurred_at: :desc)
    end

    def update
      JobApplicationWorkflow.update(
        application: @application,
        actor: current_user,
        membership: current_membership,
        status: params[:status]
      )
      redirect_to recruiting_application_path(@application), notice: "Application moved to #{@application.status.humanize}."
    rescue JobApplicationWorkflow::InvalidTransition, ActiveRecord::RecordInvalid => error
      redirect_to recruiting_application_path(@application), alert: error.message
    end

    private

    def scoped_applications
      scope = current_tenant.job_applications
      location_scoped? ? scope.where(location_id: current_membership.location_id) : scope
    end

    def set_application
      @application = scoped_applications.includes(:job_applicant, :job_posting, :location).find(params[:id])
    end

    def require_recruiting_access!
      return if current_tenant.feature_enabled?(:recruiting) && can_access_recruiting?

      redirect_to root_path, alert: "Recruiting access is not available."
    end
  end
end
