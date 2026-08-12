class Membership < ApplicationRecord
  belongs_to :tenant
  belongs_to :user
  belongs_to :location, optional: true
  has_many :sessions, dependent: :nullify

  enum :role, {
    agency_admin: 0,
    client_owner: 1,
    location_manager: 2,
    viewer: 3
  }

  ROLE_LABELS = {
    "agency_admin" => "Agency admin",
    "client_owner" => "Owner",
    "location_manager" => "Manager",
    "viewer" => "Viewer"
  }.freeze

  validates :user_id, uniqueness: { scope: :tenant_id }
  validate :location_belongs_to_tenant
  validate :location_manager_has_location

  def role_label
    ROLE_LABELS.fetch(role)
  end

  def accessible_locations
    location_manager? ? tenant.locations.where(id: location_id) : tenant.locations.all
  end

  def can_manage_leads?
    agency_admin? || client_owner? || location_manager?
  end

  def can_access_recruiting?
    !viewer?
  end

  def can_manage_recruiting?
    agency_admin? || client_owner?
  end

  private

  def location_belongs_to_tenant
    return if location.blank? || location.tenant_id == tenant_id

    errors.add(:location, "must belong to the membership tenant")
  end

  def location_manager_has_location
    errors.add(:location, "is required for a location manager") if location_manager? && location.blank?
  end
end
