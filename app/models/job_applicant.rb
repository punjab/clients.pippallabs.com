class JobApplicant < ApplicationRecord
  belongs_to :tenant
  has_many :job_applications, dependent: :restrict_with_exception

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  normalizes :phone, with: ->(phone) { phone.to_s.gsub(/[^\d+]/, "").presence }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { scope: :tenant_id }, format: { with: URI::MailTo::EMAIL_REGEXP }
end
