require "test_helper"

class TenantIsolationTest < ActionDispatch::IntegrationTest
  test "a location manager only sees locations in their tenant and assigned scope" do
    northstar = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    outsider = Tenant.create!(name: "Outsider Pizza", slug: "outsider")
    downtown = northstar.locations.create!(name: "Downtown", key: "downtown")
    north = northstar.locations.create!(name: "North", key: "north")
    outsider.locations.create!(name: "Private", key: "private")

    manager = User.create!(name: "Maya Chen", email_address: "maya@example.com", password: "secret-pass-123")
    Membership.create!(user: manager, tenant: northstar, role: :location_manager, location: downtown)

    post session_path, params: { email_address: manager.email_address, password: "secret-pass-123" }
    get v1_locations_path, as: :json

    assert_response :success
    assert_equal [ downtown.id ], response.parsed_body.pluck("id")
    assert_not_includes response.body, north.name
    assert_not_includes response.body, "Private"
  end
end
