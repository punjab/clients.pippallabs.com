class ReportGenerator
  VERSION = 1

  def self.call(tenant:, period_start:, period_end:, location: nil)
    new(tenant:, period_start:, period_end:, location:).call
  end

  def initialize(tenant:, period_start:, period_end:, location: nil)
    @tenant = tenant
    @period_start = period_start
    @period_end = period_end
    @location = location
  end

  def call
    report = tenant.reports.find_or_initialize_by(location:, period_start:, period_end:, version: VERSION)
    report.update!(
      status: :ready,
      metrics: Metrics::Summary.call(tenant:, from: period_start, to: period_end, location_ids: location&.id),
      generated_at: Time.current,
      generation_error: nil
    )
    report
  rescue StandardError => error
    report&.update_columns(status: Report.statuses[:failed], generation_error: error.message.to_s.first(2_000)) if report&.persisted?
    raise
  end

  private

  attr_reader :tenant, :period_start, :period_end, :location
end
