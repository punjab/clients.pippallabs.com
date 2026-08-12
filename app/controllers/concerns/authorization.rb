module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :super_admin?, :agency_access?, :can_access_recruiting?, :can_manage_recruiting?, :current_role_label
  end

  private

  def super_admin?
    current_user&.super_admin? || false
  end

  def agency_access?
    super_admin? || current_membership&.agency_admin? || false
  end

  def can_manage_leads?
    super_admin? || current_membership&.can_manage_leads? || false
  end

  def can_access_recruiting?
    super_admin? || current_membership&.can_access_recruiting? || false
  end

  def can_manage_recruiting?
    super_admin? || current_membership&.can_manage_recruiting? || false
  end

  def location_scoped?
    !super_admin? && current_membership&.location_manager? || false
  end

  def accessible_locations
    super_admin? ? current_tenant.locations.all : current_membership.accessible_locations
  end

  def current_role_label
    super_admin? ? "Super admin" : current_membership.role_label
  end

  def require_agency_admin!
    redirect_to root_path, alert: "Agency admin access is required." unless agency_access?
  end
end
