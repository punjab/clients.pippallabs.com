require "test_helper"

class DashboardUiTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    @location = @tenant.locations.create!(name: "Downtown", key: "downtown")
    @user = User.create!(name: "Asha Kapoor", email_address: "asha@example.com", password: "secret-pass-123")
    Membership.create!(tenant: @tenant, user: @user, role: :agency_admin)
    @website = Website.create!(tenant: @tenant, fallback_location: @location, name: "Main", allowed_domain: "pizza.example")
    @contact = @tenant.contacts.create!(name: "Alex Rivera", email: "alex@example.com")
    @lead = @tenant.leads.create!(website: @website, contact: @contact, location: @location, idempotency_key: "lead-100", lead_type: "catering", occurred_at: Time.current, message: "Lunch for 35", request_id: "req-100")
    @lead.histories.create!(tenant: @tenant, change_type: "created", to_status: "new", occurred_at: Time.current)

    post session_path, params: { email_address: @user.email_address, password: "secret-pass-123" }
  end

  test "the authenticated product pages render the core workflow" do
    get root_path
    assert_response :success
    assert_select "h1", text: /Demand, through to outcome/

    get leads_path
    assert_response :success
    assert_select "a[href='#{lead_path(@lead)}']"

    get lead_path(@lead)
    assert_response :success
    assert_select "h1", text: "Alex Rivera"

    get locations_path
    assert_response :success
    assert_select "h2", text: "Downtown"

    get insights_path
    assert_response :success
    assert_select "h1", text: /What creates intent/

    get reports_path
    assert_response :success
    assert_select "h1", text: /credible account-level story/

    get workspace_path
    assert_response :success
    assert_select "h1", text: /Configure Northstar Pizza/
  end
end
