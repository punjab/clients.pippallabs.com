module V1
  class PublicController < ApplicationController
    allow_unauthenticated_access
    skip_forgery_protection

    before_action :reject_oversized_payload
    rate_limit to: 240, within: 1.minute, by: -> { request.remote_ip }, with: -> { render json: { error: "rate_limited" }, status: :too_many_requests }

    private

    def website_from_key
      Website.authenticate_key(params[:tracking_key]) || render(
        json: { error: "invalid_tracking_key", request_id: request.request_id },
        status: :unauthorized
      )
    end

    def reject_oversized_payload
      return if request.content_length.to_i <= 64.kilobytes

      render json: { error: "payload_too_large", request_id: request.request_id }, status: :payload_too_large
    end

    def render_validation_error(record)
      render json: {
        error: "invalid_payload",
        details: record.errors.to_hash,
        request_id: request.request_id
      }, status: :unprocessable_entity
    end
  end
end
