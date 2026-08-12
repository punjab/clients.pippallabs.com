class JobApplicationIngestor
  Result = Data.define(:job_application, :duplicate)

  def self.call(website:, attributes:, request_id:)
    new(website:, attributes:, request_id:).call
  end

  def initialize(website:, attributes:, request_id:)
    @website = website
    @attributes = attributes
    @request_id = request_id
  end

  def call
    existing = tenant.job_applications.find_by(idempotency_key: attributes[:idempotency_key])
    return Result.new(job_application: existing, duplicate: true) if existing

    application = tenant.transaction do
      applicant = resolve_applicant
      created = tenant.job_applications.create!(application_attributes.merge(website:, job_applicant: applicant, job_posting:, location:))
      created.histories.create!(tenant:, change_type: "created", to_status: "new", occurred_at: Time.current)
      created
    end
    Result.new(job_application: application, duplicate: false)
  rescue ActiveRecord::RecordNotUnique
    Result.new(job_application: tenant.job_applications.find_by!(idempotency_key: attributes[:idempotency_key]), duplicate: true)
  end

  private

  attr_reader :website, :attributes, :request_id

  delegate :tenant, to: :website

  def job_posting
    @job_posting ||= tenant.job_postings.status_open.find_by!(key: attributes[:position_key])
  end

  def location
    @location ||= job_posting.location || tenant.locations.active.find_by(key: attributes[:location_key]) || website.fallback_location
  end

  def resolve_applicant
    applicant = tenant.job_applicants.find_or_initialize_by(email: attributes[:email].to_s.strip.downcase)
    applicant.name = attributes[:name] if applicant.new_record? || attributes[:name].present?
    applicant.phone = attributes[:phone] if applicant.phone.blank? && attributes[:phone].present?
    applicant.save!
    applicant
  end

  def application_attributes
    attributes.slice(
      :idempotency_key, :occurred_at, :availability, :experience, :motivation,
      :source, :page_url, :privacy_notice_version, :future_opportunities_consent
    ).merge(request_id:)
  end
end
