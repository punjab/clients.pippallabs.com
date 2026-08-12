module V1
  class JobApplicationsController < PublicController
    rate_limit to: 30, within: 1.minute, by: -> { request.remote_ip }, with: -> { render json: { error: "rate_limited" }, status: :too_many_requests }

    def create
      website = website_from_key
      return if performed?
      return render json: { error: "feature_disabled", request_id: request.request_id }, status: :not_found unless website.tenant.feature_enabled?(:recruiting)

      result = JobApplicationIngestor.call(website:, attributes: application_params.to_h.symbolize_keys, request_id: request.request_id)
      render json: { accepted: true, application_id: result.job_application.id, duplicate: result.duplicate },
        status: result.duplicate ? :ok : :created
    rescue ActiveRecord::RecordNotFound
      render json: { error: "position_not_found", request_id: request.request_id }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => error
      render_validation_error(error.record)
    end

    private

    def application_params
      params.permit(
        :idempotency_key, :position_key, :occurred_at, :name, :email, :phone,
        :availability, :experience, :motivation, :location_key, :source,
        :page_url, :privacy_notice_version, :future_opportunities_consent
      )
    end
  end
end
