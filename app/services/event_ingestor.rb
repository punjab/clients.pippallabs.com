class EventIngestor
  Result = Data.define(:event, :duplicate)

  def self.call(website:, attributes:, request_id:)
    new(website:, attributes:, request_id:).call
  end

  def initialize(website:, attributes:, request_id:)
    @website = website
    @attributes = attributes
    @request_id = request_id
  end

  def call
    existing = website.tenant.events.find_by(event_id: attributes[:event_id])
    return Result.new(event: existing, duplicate: true) if existing

    event = website.events.build(event_attributes)
    event.tenant = website.tenant
    event.location = resolve_location
    event.save!
    Result.new(event:, duplicate: false)
  rescue ActiveRecord::RecordNotUnique
    Result.new(event: website.tenant.events.find_by!(event_id: attributes[:event_id]), duplicate: true)
  end

  private

  attr_reader :website, :attributes, :request_id

  def event_attributes
    attributes.slice(
      :event_id, :event_type, :occurred_at, :session_id, :anonymous_id,
      :page_url, :landing_page, :referrer, :utm_source, :utm_medium,
      :utm_campaign, :utm_term, :utm_content, :device_class, :metadata
    ).merge(
      accepted_at: Time.current,
      request_id:,
      landing_page: attributes[:landing_page].presence || "unknown",
      referrer: attributes[:referrer].presence || "unknown",
      utm_source: attributes[:utm_source].presence || "unknown",
      utm_medium: attributes[:utm_medium].presence || "unknown",
      utm_campaign: attributes[:utm_campaign].presence || "unknown",
      utm_term: attributes[:utm_term].presence || "unknown",
      utm_content: attributes[:utm_content].presence || "unknown",
      device_class: attributes[:device_class].presence || "unknown"
    )
  end

  def resolve_location
    key = attributes[:location_key].presence
    return website.tenant.locations.active.find_by(key:) if key

    website.fallback_location || website.tenant.locations.active.find_by(key: website.tenant.default_location_key)
  end
end
