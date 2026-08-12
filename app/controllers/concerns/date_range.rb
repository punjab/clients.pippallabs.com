module DateRange
  extend ActiveSupport::Concern

  private

  def selected_date_range(default_days: 30)
    to = params[:to].present? ? Date.iso8601(params[:to]) : Date.current
    from = params[:from].present? ? Date.iso8601(params[:from]) : to - (default_days - 1).days
    raise ArgumentError if to < from || (to - from).to_i > 366

    from..to
  rescue Date::Error, ArgumentError
    redirect_to url_for(controller: controller_path, action: action_name, only_path: true), alert: "Choose a valid date range of one year or less."
    nil
  end

  def selected_location_ids
    return current_membership.location_id if location_scoped?
    return if params[:location_id].blank?

    accessible_locations.where(id: params[:location_id]).pluck(:id)
  end
end
