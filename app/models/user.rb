class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :tenants, through: :memberships
  has_many :owned_leads, class_name: "Lead", foreign_key: :owner_id, dependent: :nullify, inverse_of: :owner
  has_many :lead_histories, foreign_key: :actor_id, dependent: :nullify, inverse_of: :actor

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :name, :email_address, presence: true
  validates :email_address, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
end
