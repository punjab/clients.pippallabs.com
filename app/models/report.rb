class Report < ApplicationRecord
  belongs_to :tenant
  belongs_to :location, optional: true

  enum :status, { pending: 0, ready: 1, failed: 2 }, prefix: true

  validates :period_start, :period_end, :version, presence: true
  validates :version, numericality: { greater_than: 0 }
  validate :valid_period
  validate :location_belongs_to_tenant

  private

  def valid_period
    errors.add(:period_end, "must be on or after the start") if period_start && period_end && period_end < period_start
  end

  def location_belongs_to_tenant
    errors.add(:location, "must belong to tenant") if location && location.tenant_id != tenant_id
  end
end
