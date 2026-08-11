class GenerateMonthlyReportsJob < ApplicationJob
  queue_as :default

  def perform(month: 1.month.ago.to_date)
    period_start = month.beginning_of_month
    period_end = month.end_of_month

    Tenant.find_each do |tenant|
      ReportGenerator.call(tenant:, period_start:, period_end:)
      tenant.locations.active.find_each do |location|
        ReportGenerator.call(tenant:, period_start:, period_end:, location:)
      end
    end
  end
end
