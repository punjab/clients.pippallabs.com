module V1
  class DashboardController < BaseController
    def summary
      from, to = date_range
      render json: Metrics::Summary.call(
        tenant: current_membership.tenant,
        from:,
        to:,
        location_ids: current_membership.location_manager? ? current_membership.location_id : permitted_location_ids
      )
    rescue ArgumentError
      render json: { error: "invalid_date_range" }, status: :unprocessable_entity
    end

    private

    def date_range
      to = params[:to].present? ? Date.iso8601(params[:to]) : Date.current
      from = params[:from].present? ? Date.iso8601(params[:from]) : to - 29.days
      raise ArgumentError if to < from || (to - from).to_i > 366

      [ from, to ]
    end

    def permitted_location_ids
      return if params[:location_id].blank?

      current_membership.accessible_locations.where(id: params[:location_id]).pluck(:id)
    end
  end
end
