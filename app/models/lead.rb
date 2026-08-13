class Lead < ApplicationRecord
  TYPES = %w[catering general franchise event newsletter other].freeze
  ACTIVE_STATUSES = %w[new contacted quoted].freeze
  TERMINAL_STATUSES = %w[won lost spam].freeze

  belongs_to :tenant
  belongs_to :website
  belongs_to :contact
  belongs_to :location, optional: true
  belongs_to :owner, class_name: "User", optional: true, inverse_of: :owned_leads
  has_many :histories, class_name: "LeadHistory", dependent: :restrict_with_exception
  has_many :notifications, dependent: :restrict_with_exception

  enum :status, { new: 0, contacted: 1, quoted: 2, won: 3, lost: 4, spam: 5 }, prefix: true

  validates :idempotency_key, :request_id, presence: true
  validates :idempotency_key, uniqueness: { scope: :tenant_id }
  validates :lead_type, inclusion: { in: TYPES }
  validates :estimated_value, :actual_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :lost_has_reason
  validate :tenant_boundaries_match

  scope :non_spam, -> { where.not(status: statuses[:spam]) }
  scope :newsletter, -> { where(lead_type: "newsletter") }
  scope :non_newsletter, -> { where.not(lead_type: "newsletter") }
  scope :active, -> { where(status: ACTIVE_STATUSES.map { |name| statuses.fetch(name) }) }
  scope :overdue, -> { active.where(follow_up_at: ...Time.current) }

  def terminal?
    TERMINAL_STATUSES.include?(status)
  end

  private

  def lost_has_reason
    errors.add(:lost_reason, "is required when a lead is lost") if status_lost? && lost_reason.blank?
  end

  def tenant_boundaries_match
    errors.add(:website, "must belong to tenant") if website && website.tenant_id != tenant_id
    errors.add(:contact, "must belong to tenant") if contact && contact.tenant_id != tenant_id
    errors.add(:location, "must belong to tenant") if location && location.tenant_id != tenant_id
    return unless owner && !Membership.exists?(tenant_id:, user_id: owner.id)

    errors.add(:owner, "must be a member of the tenant")
  end
end
