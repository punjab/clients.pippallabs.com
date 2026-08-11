require "test_helper"

class GenerateMonthlyReportsJobTest < ActiveJob::TestCase
  test "it creates matching account and location summaries for the previous month" do
    tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    tenant.locations.create!(name: "Downtown", key: "downtown")
    month = Date.new(2026, 7, 1)

    assert_difference -> { Report.count }, 2 do
      GenerateMonthlyReportsJob.perform_now(month:)
    end

    assert_equal [ nil, "Downtown" ], tenant.reports.includes(:location).map { |report| report.location&.name }.sort_by(&:to_s)
    assert tenant.reports.all?(&:status_ready?)
  end
end
