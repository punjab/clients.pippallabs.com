class Location < ApplicationRecord
  belongs_to :tenant
  has_many :memberships, dependent: :nullify
  has_many :events, dependent: :nullify
  has_many :leads, dependent: :nullify
  has_many :notifications, dependent: :nullify
  has_many :reports, dependent: :destroy

  validates :name, :key, presence: true
  validates :key, uniqueness: { scope: :tenant_id }, format: { with: /\A[a-z0-9-]+\z/ }
  validate :alert_email_is_valid

  scope :active, -> { where(active: true) }

  private

  def alert_email_is_valid
    return if alert_email.blank? || alert_email.match?(URI::MailTo::EMAIL_REGEXP)

    errors.add(:alert_email, "is invalid")
  end
end
