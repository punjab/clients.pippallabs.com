class RecruitingController < ApplicationController
  before_action :require_recruiting_access!

  def show
    @job_postings = scoped_job_postings.order(status: :asc, title: :asc)
    @locations = current_membership.accessible_locations.active.order(:name)
    @job_applications = scoped_job_applications.includes(:job_applicant, :job_posting, :location).order(created_at: :desc)
  end

  def scoped_job_applications
    scope = current_tenant.job_applications
    current_membership.location_manager? ? scope.where(location_id: current_membership.location_id) : scope
  end

  private

  def scoped_job_postings
    scope = current_tenant.job_postings.includes(:location)
    current_membership.location_manager? ? scope.where(location_id: current_membership.location_id) : scope
  end

  def require_recruiting_access!
    return if current_tenant.feature_enabled?(:recruiting) && current_membership.can_access_recruiting?

    redirect_to root_path, alert: "Recruiting access is not available."
  end
end
