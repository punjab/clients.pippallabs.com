require "test_helper"

class NewsletterInboxTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    @location = @tenant.locations.create!(name: "Downtown", key: "downtown")
    @user = User.create!(name: "Asha Kapoor", email_address: "asha@example.com", password: "secret-pass-123")
    Membership.create!(tenant: @tenant, user: @user, role: :agency_admin)
    @website = Website.create!(tenant: @tenant, fallback_location: @location, name: "Main", allowed_domain: "pizza.example")

    # Tenant-local noon keeps the UTC date and the tenant-zone date identical for metrics.
    @occurred_at = Time.use_zone(@tenant.time_zone) { Time.current.noon }

    catering_contact = @tenant.contacts.create!(name: "Alex Rivera", email: "alex@example.com")
    @catering_lead = @tenant.leads.create!(website: @website, contact: catering_contact, location: @location, idempotency_key: "lead-100", lead_type: "catering", occurred_at: @occurred_at, message: "Lunch for 35", request_id: "req-100")

    subscriber = @tenant.contacts.create!(email: "subscriber@example.com", email_consent: true, email_consent_at: Time.current, email_consent_source: "newsletter_form")
    @newsletter_lead = @tenant.leads.create!(website: @website, contact: subscriber, location: @location, idempotency_key: "newsletter-100", lead_type: "newsletter", occurred_at: @occurred_at, request_id: "req-101")

    post session_path, params: { email_address: @user.email_address, password: "secret-pass-123" }
  end

  test "newsletter signups appear in the newsletter inbox, not the lead inbox" do
    get leads_path
    assert_response :success
    assert_select "a[href='#{lead_path(@catering_lead)}']"
    assert_no_match "subscriber@example.com", response.body
    assert_select "select[name='type'] option", { text: "Newsletter", count: 0 }

    get newsletter_path
    assert_response :success
    assert_match "subscriber@example.com", response.body
    assert_no_match "alex@example.com", response.body
    assert_select "a[href='#{newsletter_path(format: :csv)}']", text: "Export CSV"
  end

  test "newsletter signups export as csv" do
    get newsletter_path(format: :csv)
    assert_response :success
    assert_equal "text/csv", response.media_type

    lines = response.body.split("\n")
    assert_equal "email,consent,consent_at,signed_up_at", lines.first
    assert_equal 2, lines.size
    assert lines.second.start_with?("subscriber@example.com,true,"), "unexpected csv row: #{lines.second}"
    assert_no_match "alex@example.com", response.body
  end

  test "newsletter signups stay out of dashboard metrics" do
    summary = Metrics::Summary.call(tenant: @tenant, from: @occurred_at.to_date, to: @occurred_at.to_date)
    assert_equal 1, summary[:totals][:leads]
    assert_equal 1, summary[:trend].sum { |point| point[:leads] }

    get root_path
    assert_response :success
    assert_no_match "subscriber@example.com", response.body
  end
end
