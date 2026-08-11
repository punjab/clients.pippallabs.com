class InsightsController < ApplicationController
  include DateRange

  def show
    @range = selected_date_range
    return unless @range

    @summary = Metrics::Summary.call(tenant: current_tenant, from: @range.begin, to: @range.end, location_ids: selected_location_ids)
    render :index
  end
end
