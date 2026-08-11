class Notification < ApplicationRecord
  KINDS = %w[new_lead].freeze

  belongs_to :tenant
  belongs_to :lead
  belongs_to :location, optional: true

  enum :status, { pending: 0, delivered: 1, failed: 2, suppressed: 3 }, prefix: true

  validates :kind, inclusion: { in: KINDS }
  validates :kind, uniqueness: { scope: :lead_id }
  validate :tenant_matches_lead

  private

  def tenant_matches_lead
    errors.add(:tenant, "must match lead") if lead && lead.tenant_id != tenant_id
  end
end
