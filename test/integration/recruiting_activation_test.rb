require "test_helper"

class RecruitingActivationTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = Tenant.create!(name: "Curry Pizza Company", slug: "curry-pizza-company")
    @tenant.locations.create!(name: "Surrey", key: "surrey")
    @admin = User.create!(name: "Agency Admin", email_address: "agency@example.com", password: "secret-pass-123")
    Membership.create!(tenant: @tenant, user: @admin, role: :agency_admin)

    post session_path, params: { email_address: @admin.email_address, password: "secret-pass-123" }
  end

  test "an agency administrator can activate recruiting for a client workspace" do
    get workspace_path
    assert_response :success
    assert_select "form[action='/workspace/features/recruiting']"
    assert_select "a[href='/recruiting']", count: 0

    patch "/workspace/features/recruiting", params: { enabled: "1" }
    assert_redirected_to workspace_path

    get root_path
    assert_select "a[href='/recruiting']", text: /Recruiting/
  end
end
