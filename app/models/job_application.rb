class JobApplication < ApplicationRecord
  STATUSES = %w[new reviewing interview offered hired rejected withdrawn].freeze

  belongs_to :tenant
  belongs_to :website
  belongs_to :job_posting
  belongs_to :job_applicant
  belongs_to :location, optional: true
  has_many :histories, class_name: "JobApplicationHistory", dependent: :restrict_with_exception

  enum :status, STATUSES.each_with_index.to_h, prefix: true

  validates :idempotency_key, :occurred_at, :privacy_notice_version, :request_id, presence: true
  validates :idempotency_key, uniqueness: { scope: :tenant_id }
  validate :tenant_boundaries_match
  validate :occurred_at_is_plausible
  validate :page_url_matches_website

  private

  def tenant_boundaries_match
    errors.add(:website, "must belong to tenant") if website && website.tenant_id != tenant_id
    errors.add(:job_posting, "must belong to tenant") if job_posting && job_posting.tenant_id != tenant_id
    errors.add(:job_applicant, "must belong to tenant") if job_applicant && job_applicant.tenant_id != tenant_id
    errors.add(:location, "must belong to tenant") if location && location.tenant_id != tenant_id
  end

  def page_url_matches_website
    return if page_url.blank? || page_url == "unknown" || website.blank?

    uri = URI.parse(page_url)
    unless uri.is_a?(URI::HTTP) && uri.host.present? && uri.userinfo.blank?
      errors.add(:page_url, "must be a public HTTP URL")
      return
    end

    host = uri.host.downcase
    allowed = website.allowed_domain
    errors.add(:page_url, "must use the configured website domain") unless host == allowed || host.end_with?(".#{allowed}")
  rescue URI::InvalidURIError
    errors.add(:page_url, "must be a valid URL")
  end

  def occurred_at_is_plausible
    return if occurred_at.blank?

    errors.add(:occurred_at, "is too far in the future") if occurred_at > 5.minutes.from_now
    errors.add(:occurred_at, "is too old") if occurred_at < 13.months.ago
  end
end
