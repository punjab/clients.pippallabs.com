class ReportsController < ApplicationController
  before_action :set_report, only: :show

  def index
    @reports = scoped_reports.includes(:location).order(period_start: :desc, location_id: :asc)
  end

  def show
  end

  def create
    month = params[:month].present? ? Date.strptime(params[:month], "%Y-%m") : Date.current.beginning_of_month
    location = params[:location_id].present? ? current_membership.accessible_locations.find(params[:location_id]) : nil
    location ||= current_membership.location if current_membership.location_manager?
    report = ReportGenerator.call(tenant: current_tenant, period_start: month.beginning_of_month, period_end: month.end_of_month, location:)
    redirect_to report_path(report), notice: "Monthly summary generated from current source records."
  rescue Date::Error, ActiveRecord::RecordNotFound
    redirect_to reports_path, alert: "Choose a valid month and location."
  end

  private

  def scoped_reports
    scope = current_tenant.reports.status_ready
    current_membership.location_manager? ? scope.where(location_id: current_membership.location_id) : scope
  end

  def set_report
    @report = scoped_reports.find(params[:id])
  end
end
