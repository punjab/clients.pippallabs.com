class Contact < ApplicationRecord
  belongs_to :tenant
  has_many :leads, dependent: :restrict_with_exception

  normalizes :email, with: ->(email) { normalize_email(email) }
  normalizes :phone, with: ->(phone) { normalize_phone(phone) }

  validates :email, uniqueness: { scope: :tenant_id }, allow_nil: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :phone, uniqueness: { scope: :tenant_id }, allow_nil: true
  validate :has_identity

  def self.normalize_email(value)
    value.to_s.strip.downcase.presence
  end

  def self.normalize_phone(value)
    digits = value.to_s.gsub(/\D/, "")
    return if digits.blank?

    digits = "1#{digits}" if digits.length == 10
    "+#{digits}"
  end

  private

  def has_identity
    errors.add(:base, "email or phone is required") if email.blank? && phone.blank?
  end
end
