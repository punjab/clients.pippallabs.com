class LeadIngestor
  Result = Data.define(:lead, :duplicate)

  def self.call(website:, attributes:, request_id:)
    new(website:, attributes:, request_id:).call
  end

  def initialize(website:, attributes:, request_id:)
    @website = website
    @attributes = attributes
    @request_id = request_id
  end

  def call
    existing = tenant.leads.find_by(idempotency_key: attributes[:idempotency_key])
    return Result.new(lead: existing, duplicate: true) if existing

    notification = nil
    lead = tenant.transaction do
      contact = ContactResolver.call(tenant:, attributes:)
      created_lead = tenant.leads.create!(lead_attributes.merge(website:, contact:, location: resolve_location))
      created_lead.histories.create!(tenant:, change_type: "created", to_status: created_lead.status, occurred_at: Time.current)
      if alertable?(created_lead)
        notification = build_notification(created_lead)
        notification.save!
      end
      created_lead
    end
    LeadAlertJob.perform_later(notification) if notification&.status_pending?
    Result.new(lead:, duplicate: false)
  rescue ActiveRecord::RecordNotUnique
    Result.new(lead: tenant.leads.find_by!(idempotency_key: attributes[:idempotency_key]), duplicate: true)
  end

  private

  attr_reader :website, :attributes, :request_id

  delegate :tenant, to: :website

  def lead_attributes
    attributes.slice(
      :idempotency_key, :lead_type, :occurred_at, :message, :source, :page_url,
      :utm_source, :utm_medium, :utm_campaign, :estimated_value
    ).merge(
      request_id:,
      source: attributes[:source].presence || "unknown",
      page_url: attributes[:page_url].presence || "unknown",
      utm_source: attributes[:utm_source].presence || "unknown",
      utm_medium: attributes[:utm_medium].presence || "unknown",
      utm_campaign: attributes[:utm_campaign].presence || "unknown"
    )
  end

  def resolve_location
    key = attributes[:location_key].presence
    return tenant.locations.active.find_by(key:) if key

    website.fallback_location || tenant.locations.active.find_by(key: tenant.default_location_key)
  end

  def alertable?(lead)
    lead.lead_type != "newsletter"
  end

  def build_notification(lead)
    recipient = lead.location&.alert_email.presence || tenant.notification_email.presence
    lead.notifications.build(
      tenant:,
      location: lead.location,
      kind: "new_lead",
      recipient:,
      status: recipient ? :pending : :failed,
      last_error: recipient ? nil : "No lead alert recipient is configured"
    )
  end
end
