class Event < ApplicationRecord
  TYPES = %w[page_view order_click call_click coupon_click location_click cta_click].freeze
  METADATA_KEYS = %w[target_url coupon_id location_identifier cta_name].freeze

  belongs_to :tenant
  belongs_to :website
  belongs_to :location, optional: true

  validates :event_id, :session_id, :page_url, :request_id, presence: true
  validates :event_type, inclusion: { in: TYPES }
  validates :event_id, uniqueness: { scope: :tenant_id }
  validate :occurred_at_is_plausible
  validate :urls_are_public_http_urls
  validate :page_url_matches_website
  validate :metadata_is_safe
  validate :tenant_boundaries_match

  scope :accepted, -> { where(bot: false, internal: false) }

  private

  def occurred_at_is_plausible
    return if occurred_at.blank?

    errors.add(:occurred_at, "is too far in the future") if occurred_at > 5.minutes.from_now
    errors.add(:occurred_at, "is too old") if occurred_at < 13.months.ago
  end

  def urls_are_public_http_urls
    %i[page_url landing_page referrer].each do |field|
      value = public_send(field)
      next if value.blank? || value == "unknown"

      uri = URI.parse(value)
      errors.add(field, "must be an HTTP URL") unless uri.is_a?(URI::HTTP) && uri.host.present? && uri.userinfo.blank?
    rescue URI::InvalidURIError
      errors.add(field, "must be a valid URL")
    end
  end

  def metadata_is_safe
    errors.add(:metadata, "has too many fields") if metadata.to_h.size > 20
    unsafe_keys = metadata.to_h.keys.map(&:to_s) - METADATA_KEYS
    errors.add(:metadata, "contains unsupported fields: #{unsafe_keys.join(', ')}") if unsafe_keys.any?
  end

  def page_url_matches_website
    return if page_url.blank? || website.blank?

    host = URI.parse(page_url).host.to_s.downcase
    allowed = website.allowed_domain
    errors.add(:page_url, "must use the configured website domain") unless host == allowed || host.end_with?(".#{allowed}")
  rescue URI::InvalidURIError
    # The URL format validator reports the actionable error.
  end

  def tenant_boundaries_match
    errors.add(:website, "must belong to tenant") if website && website.tenant_id != tenant_id
    errors.add(:location, "must belong to tenant") if location && location.tenant_id != tenant_id
  end
end
