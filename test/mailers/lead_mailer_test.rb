require "test_helper"

class LeadMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    @location = @tenant.locations.create!(name: "Downtown", key: "downtown", alert_email: "downtown@pizza.example")
    @website = Website.create!(tenant: @tenant, fallback_location: @location, name: "Main", allowed_domain: "pizza.example")
    contact = @tenant.contacts.create!(name: "Alex Rivera", email: "alex@example.com", phone: "+15595550100")
    @lead = @tenant.leads.create!(website: @website, contact: contact, location: @location, idempotency_key: "lead-100", lead_type: "catering", occurred_at: Time.current, message: "Event date: 2026-08-21\n\nLunch for 35 people.", request_id: "req-100")
    @notification = @lead.notifications.create!(tenant: @tenant, location: @location, kind: "new_lead", recipient: @location.alert_email)
  end

  test "new lead alert renders both parts with contact details and lead link" do
    email = LeadMailer.with(notification: @notification).new_lead

    assert_equal [ "downtown@pizza.example" ], email.to
    assert_equal "New catering lead from Alex Rivera", email.subject

    html = email.html_part.body.to_s
    assert_includes html, "New catering lead"
    assert_includes html, "Alex Rivera"
    assert_includes html, "alex@example.com"
    assert_includes html, "Downtown"
    assert_includes html, lead_url(@lead, host: "example.com")
    assert_includes html, "white-space:pre-line"
    assert_not_includes html, "**"

    text = email.text_part.body.to_s
    assert_includes text, "New catering lead"
    assert_includes text, "Lunch for 35 people."
    assert_includes text, lead_url(@lead, host: "example.com")
  end
end
