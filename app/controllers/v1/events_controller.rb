module V1
  class EventsController < PublicController
    def create
      website = website_from_key
      return if performed?

      unsupported_metadata = params[:metadata].respond_to?(:keys) ? params[:metadata].keys.map(&:to_s) - Event::METADATA_KEYS : []
      if unsupported_metadata.any?
        return render json: {
          error: "invalid_payload",
          details: { metadata: [ "contains unsupported fields: #{unsupported_metadata.join(', ')}" ] },
          request_id: request.request_id
        }, status: :unprocessable_entity
      end

      result = EventIngestor.call(website:, attributes: event_params.to_h.symbolize_keys, request_id: request.request_id)
      render json: { accepted: true, event_id: result.event.event_id, duplicate: result.duplicate },
        status: result.duplicate ? :ok : :accepted
    rescue ActiveRecord::RecordInvalid => error
      render_validation_error(error.record)
    end

    private

    def event_params
      params.permit(
        :event_id, :event_type, :occurred_at, :session_id, :anonymous_id,
        :page_url, :landing_page, :referrer, :location_key, :utm_source,
        :utm_medium, :utm_campaign, :utm_term, :utm_content, :device_class,
        metadata: Event::METADATA_KEYS
      )
    end
  end
end
