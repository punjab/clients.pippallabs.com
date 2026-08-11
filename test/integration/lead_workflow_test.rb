require "test_helper"

class LeadWorkflowTest < ActionDispatch::IntegrationTest
  test "an authorized manager updates a lead and its audit history through the API" do
    tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    location = tenant.locations.create!(name: "Downtown", key: "downtown")
    manager = User.create!(name: "Maya Chen", email_address: "maya@example.com", password: "secret-pass-123")
    Membership.create!(tenant:, location:, user: manager, role: :location_manager)
    website = Website.create!(tenant:, fallback_location: location, name: "Main", allowed_domain: "pizza.example")
    contact = tenant.contacts.create!(name: "Alex Rivera", email: "alex@example.com")
    lead = tenant.leads.create!(website:, contact:, location:, idempotency_key: "lead-100", lead_type: "catering", occurred_at: Time.current, request_id: "req-100")

    post session_path, params: { email_address: manager.email_address, password: "secret-pass-123" }
    patch v1_lead_path(lead), params: {
      status: "contacted",
      owner_id: manager.id,
      follow_up_at: 2.days.from_now.iso8601,
      estimated_value: "1,250.00"
    }, as: :json

    assert_response :success
    assert_equal "contacted", response.parsed_body.dig("lead", "status")
    assert_equal manager.id, response.parsed_body.dig("lead", "owner", "id")
    assert_equal 4, response.parsed_body["history"].length

    post notes_v1_lead_path(lead), params: { note: "Confirmed 45 guests and a vegetarian option." }, as: :json
    assert_response :created

    get v1_lead_path(lead), as: :json
    assert_response :success
    assert_equal "Confirmed 45 guests and a vegetarian option.", response.parsed_body["history"].first["note"]
  end
end
