class JobPosting < ApplicationRecord
  belongs_to :tenant
  belongs_to :location, optional: true
  has_many :job_applications, dependent: :restrict_with_exception

  enum :status, { open: 0, closed: 1 }, prefix: true

  validates :title, :key, presence: true
  validates :key, uniqueness: { scope: :tenant_id }, format: { with: /\A[a-z0-9-]+\z/ }
  validate :location_belongs_to_tenant

  private

  def location_belongs_to_tenant
    errors.add(:location, "must belong to tenant") if location && location.tenant_id != tenant_id
  end
end
