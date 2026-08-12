require "test_helper"

class RecruitingIsolationTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = Tenant.create!(name: "Curry Pizza Company", slug: "curry-pizza-company")
    @surrey = @tenant.locations.create!(name: "Surrey", key: "surrey")
    @burnaby = @tenant.locations.create!(name: "Burnaby", key: "burnaby")
    @tenant.workspace_features.create!(key: "recruiting", enabled: true)
    @website = Website.create!(tenant: @tenant, fallback_location: @surrey, name: "Main", allowed_domain: "currypizzacompany.test", tracking_key: "pk_test_curry")
    @surrey_position = @tenant.job_postings.create!(title: "Surrey Team Member", key: "surrey-team", location: @surrey)
    @burnaby_position = @tenant.job_postings.create!(title: "Burnaby Team Member", key: "burnaby-team", location: @burnaby)
    submit_application(@surrey_position, "Sam Surrey", "sam@example.com", "application-surrey")
    @burnaby_application = submit_application(@burnaby_position, "Bailey Burnaby", "bailey@example.com", "application-burnaby")
  end

  test "a location manager can only see applicants assigned to their location" do
    manager = User.create!(name: "Surrey Manager", email_address: "manager@example.com", password: "secret-pass-123")
    Membership.create!(tenant: @tenant, location: @surrey, user: manager, role: :location_manager)
    post session_path, params: { email_address: manager.email_address, password: "secret-pass-123" }

    get recruiting_path
    assert_response :success
    assert_select "a", text: /Sam Surrey/
    assert_select "a", text: /Bailey Burnaby/, count: 0

    get recruiting_application_path(@burnaby_application)
    assert_response :not_found
  end

  test "a workspace without recruiting enabled rejects application intake" do
    other = Tenant.create!(name: "Another Client", slug: "another-client")
    location = other.locations.create!(name: "Main", key: "main")
    website = Website.create!(tenant: other, fallback_location: location, name: "Main", allowed_domain: "another.test", tracking_key: "pk_test_other")
    position = other.job_postings.create!(title: "Team Member", key: "team-member", location:)

    post v1_job_applications_path, params: application_payload(website:, position:, name: "Other Applicant", email: "other@example.com", key: "other-1"), as: :json
    assert_response :not_found
    assert_equal "feature_disabled", response.parsed_body["error"]
  end

  test "a viewer cannot discover or open applicant data" do
    viewer = User.create!(name: "Read Only", email_address: "viewer@example.com", password: "secret-pass-123")
    Membership.create!(tenant: @tenant, user: viewer, role: :viewer)
    post session_path, params: { email_address: viewer.email_address, password: "secret-pass-123" }

    get root_path
    assert_select "a[href='/recruiting']", count: 0

    get recruiting_path
    assert_redirected_to root_path
  end

  test "application intake rejects a non-HTTP page even when its hostname matches" do
    payload = application_payload(website: @website, position: @surrey_position, name: "Unsafe", email: "unsafe@example.com", key: "unsafe-1")
    payload[:page_url] = "ftp://currypizzacompany.test/careers"

    post v1_job_applications_path, params: payload, as: :json
    assert_response :unprocessable_entity
    assert response.parsed_body.dig("details", "page_url").present?
  end

  private

  def submit_application(position, name, email, key)
    post v1_job_applications_path, params: application_payload(website: @website, position:, name:, email:, key:), as: :json
    assert_response :created
    response.parsed_body.fetch("application_id")
  end

  def application_payload(website:, position:, name:, email:, key:)
    {
      tracking_key: website.tracking_key,
      idempotency_key: key,
      position_key: position.key,
      occurred_at: Time.current.iso8601,
      name:,
      email:,
      location_key: position.location.key,
      page_url: "https://#{website.allowed_domain}/careers",
      privacy_notice_version: "2026-08"
    }
  end
end
