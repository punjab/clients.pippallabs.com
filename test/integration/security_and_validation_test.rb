require "test_helper"

class SecurityAndValidationTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    @location = @tenant.locations.create!(name: "Downtown", key: "downtown")
    @website = Website.create!(tenant: @tenant, fallback_location: @location, name: "Main", allowed_domain: "pizza.example", tracking_key: "pk_test_northstar")
  end

  test "invalid public keys and personal event metadata are rejected" do
    post v1_events_path, params: valid_event.merge(tracking_key: "pk_wrong"), as: :json
    assert_response :unauthorized

    post v1_events_path, params: valid_event.merge(metadata: { email: "person@example.com" }), as: :json
    assert_response :unprocessable_entity
    assert_equal "invalid_payload", response.parsed_body["error"]
    assert_equal 0, Event.count
  end

  test "a terminal lead cannot change until reopened and lost requires a reason" do
    manager = User.create!(name: "Maya", email_address: "maya@example.com", password: "secret-pass-123")
    Membership.create!(tenant: @tenant, location: @location, user: manager, role: :location_manager)
    contact = @tenant.contacts.create!(email: "alex@example.com")
    lead = @tenant.leads.create!(website: @website, contact:, location: @location, idempotency_key: "lead-1", lead_type: "catering", status: :quoted, occurred_at: Time.current, request_id: "req-1")
    post session_path, params: { email_address: manager.email_address, password: "secret-pass-123" }

    patch v1_lead_path(lead), params: { status: "lost" }, as: :json
    assert_response :unprocessable_entity

    patch v1_lead_path(lead), params: { status: "lost", lost_reason: "Budget" }, as: :json
    assert_response :success

    patch v1_lead_path(lead), params: { status: "new" }, as: :json
    assert_response :unprocessable_entity

    post reopen_v1_lead_path(lead), as: :json
    assert_response :success
    assert_equal "new", response.parsed_body.dig("lead", "status")
  end

  private

  def valid_event
    {
      tracking_key: @website.tracking_key,
      event_id: "evt-1",
      event_type: "page_view",
      occurred_at: Time.current.iso8601,
      session_id: "session-1",
      page_url: "https://pizza.example/menu",
      metadata: {}
    }
  end
end
