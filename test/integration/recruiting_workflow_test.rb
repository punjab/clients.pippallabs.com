require "test_helper"

class RecruitingWorkflowTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = Tenant.create!(name: "Curry Pizza Company", slug: "curry-pizza-company")
    @location = @tenant.locations.create!(name: "Surrey", key: "surrey")
    @tenant.workspace_features.create!(key: "recruiting", enabled: true)
    @website = Website.create!(tenant: @tenant, fallback_location: @location, name: "Main", allowed_domain: "currypizzacompany.test", tracking_key: "pk_test_curry")
    @position = @tenant.job_postings.create!(title: "Kitchen Team Member", key: "kitchen-team-member", location: @location)
    @admin = User.create!(name: "Agency Admin", email_address: "agency@example.com", password: "secret-pass-123")
    Membership.create!(tenant: @tenant, user: @admin, role: :agency_admin)

    post session_path, params: { email_address: @admin.email_address, password: "secret-pass-123" }
  end

  test "an authorized workspace can publish a position" do
    post "/recruiting/positions", params: {
      job_posting: {
        title: "Kitchen Team Member",
        key: "kitchen-team-member",
        location_id: @location.id,
        description: "Prepare food and support a welcoming guest experience."
      }
    }
    assert_redirected_to recruiting_path

    get recruiting_path
    assert_response :success
    assert_select "h2", text: "Kitchen Team Member"
    assert_select "p", text: /kitchen-team-member/
  end

  test "a website application is accepted once and appears in the private recruiting inbox" do
    payload = {
      tracking_key: @website.tracking_key,
      idempotency_key: "application-1042",
      position_key: @position.key,
      occurred_at: Time.current.iso8601,
      name: "Sam Lee",
      email: "sam@example.com",
      phone: "+16045550142",
      availability: "Evenings and weekends",
      experience: "Two years in a busy restaurant kitchen.",
      motivation: "I enjoy serving the local community.",
      location_key: @location.key,
      source: "careers_form",
      page_url: "https://currypizzacompany.test/careers",
      privacy_notice_version: "2026-08",
      future_opportunities_consent: false
    }

    post "/v1/job_applications", params: payload, as: :json
    assert_response :created
    assert_equal false, response.parsed_body["duplicate"]

    post "/v1/job_applications", params: payload, as: :json
    assert_response :success
    assert_equal true, response.parsed_body["duplicate"]

    get recruiting_path
    assert_response :success
    assert_select "a", text: /Sam Lee/, count: 1
  end


  test "a hiring manager advances an application with an auditable history" do
    post v1_job_applications_path, params: application_payload("application-2042"), as: :json
    application_id = response.parsed_body.fetch("application_id")

    patch recruiting_application_path(application_id), params: { status: "reviewing" }
    assert_redirected_to recruiting_application_path(application_id)

    get recruiting_application_path(application_id)
    assert_response :success
    assert_select "span", text: "Reviewing"
    assert_select "li", text: /Agency Admin moved New to Reviewing/
  end

  test "closing a position prevents new applications" do
    patch "/recruiting/positions/#{@position.id}", params: { status: "closed" }
    assert_redirected_to recruiting_path

    post v1_job_applications_path, params: application_payload("application-after-close"), as: :json
    assert_response :unprocessable_entity
    assert_equal "position_not_found", response.parsed_body["error"]
  end

  private

  def application_payload(idempotency_key)
    {
      tracking_key: @website.tracking_key,
      idempotency_key:,
      position_key: @position.key,
      occurred_at: Time.current.iso8601,
      name: "Sam Lee",
      email: "sam@example.com",
      availability: "Evenings and weekends",
      location_key: @location.key,
      page_url: "https://currypizzacompany.test/careers",
      privacy_notice_version: "2026-08"
    }
  end
end
