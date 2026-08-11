class LeadHistory < ApplicationRecord
  CHANGE_TYPES = %w[created status_changed assigned follow_up_set values_changed note_added reopened].freeze

  belongs_to :tenant
  belongs_to :lead
  belongs_to :actor, class_name: "User", optional: true, inverse_of: :lead_histories

  validates :change_type, inclusion: { in: CHANGE_TYPES }
  validates :occurred_at, presence: true
  validate :tenant_matches_lead

  private

  def tenant_matches_lead
    errors.add(:tenant, "must match lead") if lead && lead.tenant_id != tenant_id
  end
end
