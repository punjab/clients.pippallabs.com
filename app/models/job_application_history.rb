class JobApplicationHistory < ApplicationRecord
  belongs_to :tenant
  belongs_to :job_application
  belongs_to :actor, class_name: "User", optional: true

  validates :change_type, :occurred_at, presence: true
  validate :tenant_matches_application

  private

  def tenant_matches_application
    errors.add(:tenant, "must match application") if job_application && job_application.tenant_id != tenant_id
  end
end
