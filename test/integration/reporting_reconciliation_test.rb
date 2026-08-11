require "test_helper"

class ReportingReconciliationTest < ActionDispatch::IntegrationTest
  test "dashboard and monthly report reconcile to the same accepted source records" do
    tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    location = tenant.locations.create!(name: "Downtown", key: "downtown")
    owner = User.create!(name: "Priya Shah", email_address: "priya@example.com", password: "secret-pass-123")
    Membership.create!(tenant:, user: owner, role: :client_owner)
    website = Website.create!(tenant:, fallback_location: location, name: "Main", allowed_domain: "pizza.example")
    july = Time.zone.parse("2026-07-15 12:00:00")

    create_event(tenant:, website:, location:, event_id: "pv-1", event_type: "page_view", session_id: "visit-1", occurred_at: july, page_url: "https://pizza.example/menu", utm_source: "google")
    create_event(tenant:, website:, location:, event_id: "pv-2", event_type: "page_view", session_id: "visit-1", occurred_at: july + 1.minute, page_url: "https://pizza.example/catering", utm_source: "google")
    create_event(tenant:, website:, location:, event_id: "pv-3", event_type: "page_view", session_id: "visit-2", occurred_at: july + 2.minutes, page_url: "https://pizza.example/menu", utm_source: "direct")
    create_event(tenant:, website:, location:, event_id: "order-1", event_type: "order_click", session_id: "visit-1", occurred_at: july + 3.minutes, page_url: "https://pizza.example/menu", utm_source: "google")
    create_event(tenant:, website:, location:, event_id: "call-1", event_type: "call_click", session_id: "visit-2", occurred_at: july + 4.minutes, page_url: "https://pizza.example/locations", utm_source: "direct")
    contact = tenant.contacts.create!(name: "Alex", email: "alex@example.com")
    create_lead(tenant:, website:, location:, contact:, key: "lead-won", status: :won, occurred_at: july, actual_value: 900)
    create_lead(tenant:, website:, location:, contact:, key: "lead-lost", status: :lost, occurred_at: july + 1.day, lost_reason: "Budget")
    create_lead(tenant:, website:, location:, contact:, key: "lead-spam", status: :spam, occurred_at: july + 2.days)

    post session_path, params: { email_address: owner.email_address, password: "secret-pass-123" }
    get v1_dashboard_summary_path, params: { from: "2026-07-01", to: "2026-07-31" }, as: :json

    assert_response :success
    summary = response.parsed_body
    assert_equal 2, summary.dig("totals", "visits")
    assert_equal 1, summary.dig("totals", "order_intent")
    assert_equal 1, summary.dig("totals", "call_intent")
    assert_equal 2, summary.dig("totals", "leads")
    assert_equal 100.0, summary.dig("totals", "lead_conversion_rate")
    assert_equal 50.0, summary.dig("totals", "win_rate")
    assert_equal "900.0", summary.dig("totals", "attributed_value")

    report = ReportGenerator.call(tenant:, period_start: Date.new(2026, 7, 1), period_end: Date.new(2026, 7, 31))
    get v1_report_path(report), as: :json
    assert_response :success
    assert_equal summary["totals"], response.parsed_body.dig("report", "metrics", "totals")
  end

  private

  def create_event(**attributes)
    Event.create!({ accepted_at: attributes[:occurred_at], landing_page: "unknown", referrer: "unknown", request_id: SecureRandom.hex(4), metadata: {} }.merge(attributes))
  end

  def create_lead(tenant:, website:, location:, contact:, key:, status:, occurred_at:, **attributes)
    Lead.create!({ tenant:, website:, location:, contact:, idempotency_key: key, lead_type: "catering", status:, occurred_at:, request_id: SecureRandom.hex(4) }.merge(attributes))
  end
end
