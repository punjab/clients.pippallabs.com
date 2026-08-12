require "test_helper"

class RoleModelTest < ActionDispatch::IntegrationTest
  setup do
    @alpha = Tenant.create!(name: "Alpha Pizza", slug: "alpha")
    @beta = Tenant.create!(name: "Beta Pizza", slug: "beta")
    @downtown = @alpha.locations.create!(name: "Downtown", key: "downtown")
    @super_admin = User.create!(name: "Sam Root", email_address: "root@pippallabs.test", password: "secret-pass-123", super_admin: true)
    @admin = User.create!(name: "Asha Kapoor", email_address: "asha@example.com", password: "secret-pass-123")
    Membership.create!(tenant: @alpha, user: @admin, role: :agency_admin)
  end

  test "a super admin with no memberships can log in, see all clients, and switch into any tenant" do
    post session_path, params: { email_address: @super_admin.email_address, password: "secret-pass-123" }
    assert_redirected_to root_path
    get root_path
    assert_response :success

    get agency_tenants_path
    assert_response :success
    assert_select "p", text: @alpha.name
    assert_select "p", text: @beta.name
    assert_select "p.eyebrow", text: "Agency admins"
    assert_select "p", text: @admin.email_address

    post switch_session_path, params: { tenant_id: @beta.id }
    assert_redirected_to root_path
    get root_path
    assert_response :success
    assert_select "header p", text: @beta.name
  end

  test "an agency admin stays restricted to their membership tenants" do
    post session_path, params: { email_address: @admin.email_address, password: "secret-pass-123" }

    post switch_session_path, params: { tenant_id: @beta.id }
    assert_response :not_found

    get agency_tenants_path
    assert_response :success
    assert_select "p", text: @alpha.name
    assert_select "p", text: @beta.name, count: 0
    assert_select "p.eyebrow", text: "Agency admins", count: 0
  end

  test "tenant creation by a super admin does not create a membership for them" do
    post session_path, params: { email_address: @super_admin.email_address, password: "secret-pass-123" }

    assert_no_difference -> { @super_admin.memberships.count } do
      post agency_tenants_path, params: { name: "Gamma Pizza", slug: "gamma", location_name: "Main", location_key: "main", allowed_domain: "gamma.example" }
    end
    assert_redirected_to workspace_path
    assert_match "Client created.", flash[:notice]
    follow_redirect!
    assert_response :success
    assert_select "h1", text: /Configure Gamma Pizza/
  end

  test "a super admin can render the recruiting page without a membership" do
    @alpha.workspace_features.create!(key: "recruiting", enabled: true)
    @alpha.job_postings.create!(title: "Line cook", key: "line-cook", status: :open)

    post session_path, params: { email_address: @super_admin.email_address, password: "secret-pass-123" }
    get recruiting_path
    assert_response :success
    assert_select "h2", text: "Line cook"
  end

  test "revoking a membership ends the session's tenant access" do
    owner = User.create!(name: "Priya Shah", email_address: "owner@example.com", password: "secret-pass-123")
    membership = Membership.create!(tenant: @alpha, user: owner, role: :client_owner)

    post session_path, params: { email_address: owner.email_address, password: "secret-pass-123" }
    get v1_leads_path, as: :json
    assert_response :success

    membership.destroy!
    get v1_leads_path, as: :json
    assert_response :unauthorized

    get leads_path
    assert_redirected_to new_session_path
  end

  test "client roles are still redirected from settings and agency pages" do
    viewer = User.create!(name: "Noah Williams", email_address: "viewer@example.com", password: "secret-pass-123")
    Membership.create!(tenant: @alpha, user: viewer, role: :viewer)

    post session_path, params: { email_address: viewer.email_address, password: "secret-pass-123" }
    [ workspace_path, agency_tenants_path ].each do |path|
      get path
      assert_redirected_to root_path
    end
    post workspace_memberships_path, params: { membership: { name: "X", email_address: "x@example.com", password: "longenough-pass-1", role: "viewer" } }
    assert_redirected_to root_path
  end

  test "role labels render as Owner, Manager, and Viewer on the People & access panel" do
    owner = User.create!(name: "Priya Shah", email_address: "priya@example.com", password: "secret-pass-123")
    manager = User.create!(name: "Maya Chen", email_address: "maya@example.com", password: "secret-pass-123")
    viewer = User.create!(name: "Noah Williams", email_address: "noah@example.com", password: "secret-pass-123")
    Membership.create!(tenant: @alpha, user: owner, role: :client_owner)
    Membership.create!(tenant: @alpha, user: manager, role: :location_manager, location: @downtown)
    Membership.create!(tenant: @alpha, user: viewer, role: :viewer)

    post session_path, params: { email_address: @admin.email_address, password: "secret-pass-123" }
    get workspace_path
    assert_response :success
    assert_select "p", text: "Agency admin"
    assert_select "p", text: "Owner"
    assert_select "p", text: "Manager · Downtown"
    assert_select "p", text: "Viewer"
  end
end
