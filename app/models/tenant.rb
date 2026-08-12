class Tenant < ApplicationRecord
  has_many :locations, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :websites, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :leads, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :workspace_features, dependent: :destroy
  has_many :job_postings, dependent: :destroy
  has_many :job_applicants, dependent: :destroy
  has_many :job_applications, dependent: :destroy
  has_many :job_application_histories, dependent: :destroy

  def feature_enabled?(key)
    workspace_features.where(key:, enabled: true).exists?
  end

  validate :notification_email_is_valid

  private

  def notification_email_is_valid
    return if notification_email.blank? || notification_email.match?(URI::MailTo::EMAIL_REGEXP)

    errors.add(:notification_email, "is invalid")
  end

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
end
