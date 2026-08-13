class DashboardController < ApplicationController
  include DateRange

  def index
    @range = selected_date_range
    return unless @range

    @summary = Metrics::Summary.call(tenant: current_tenant, from: @range.begin, to: @range.end, location_ids: selected_location_ids)
    @locations = accessible_locations.active.order(:name)
    @recent_leads = scoped_leads.non_spam.non_newsletter.includes(:contact, :location, :owner).order(created_at: :desc).limit(5)
  end

  private

  def scoped_leads
    scope = current_tenant.leads
    location_scoped? ? scope.where(location_id: current_membership.location_id) : scope
  end
end
