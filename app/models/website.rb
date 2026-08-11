class Website < ApplicationRecord
  belongs_to :tenant
  belongs_to :fallback_location, class_name: "Location", optional: true
  has_many :events, dependent: :restrict_with_exception
  has_many :leads, dependent: :restrict_with_exception

  attr_reader :tracking_key

  normalizes :allowed_domain, with: ->(domain) { domain.to_s.strip.downcase.sub(%r{\Ahttps?://}, "").split("/").first }

  validates :name, :allowed_domain, :tracking_key_digest, :tracking_key_hint, presence: true
  validates :allowed_domain, uniqueness: { scope: :tenant_id }
  validate :fallback_location_belongs_to_tenant

  before_validation :generate_tracking_key, on: :create

  scope :active, -> { where(active: true) }

  def tracking_key=(plain_key)
    @tracking_key = plain_key
    self.tracking_key_digest = self.class.digest_key(plain_key)
    self.tracking_key_hint = plain_key.to_s.last(6)
  end

  def self.authenticate_key(plain_key)
    return if plain_key.blank?

    active.find_by(tracking_key_digest: digest_key(plain_key))
  end

  def self.digest_key(plain_key)
    OpenSSL::Digest::SHA256.hexdigest(plain_key.to_s)
  end

  private

  def generate_tracking_key
    self.tracking_key = "pk_#{SecureRandom.urlsafe_base64(24)}" if tracking_key_digest.blank?
  end

  def fallback_location_belongs_to_tenant
    return if fallback_location.blank? || fallback_location.tenant_id == tenant_id

    errors.add(:fallback_location, "must belong to the website tenant")
  end
end
