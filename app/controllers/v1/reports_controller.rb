module V1
  class ReportsController < BaseController
    before_action :set_report, only: :show

    def index
      reports = scoped_reports.status_ready.order(period_start: :desc, location_id: :asc)
      render json: { reports: reports.map { |report| report_json(report, include_metrics: false) } }
    end

    def show
      render json: { report: report_json(@report, include_metrics: true) }
    end

    private

    def scoped_reports
      scope = current_tenant.reports
      location_scoped? ? scope.where(location_id: current_membership.location_id) : scope
    end

    def set_report
      @report = scoped_reports.find(params[:id])
    end

    def report_json(report, include_metrics:)
      data = {
        id: report.id,
        period_start: report.period_start,
        period_end: report.period_end,
        version: report.version,
        status: report.status,
        generated_at: report.generated_at,
        location: report.location && { id: report.location.id, name: report.location.name }
      }
      data[:metrics] = report.metrics if include_metrics
      data
    end
  end
end
