require "test_helper"

class LeadIngestionTest < ActionDispatch::IntegrationTest
  test "retrying one form submission creates one lead contact and alert" do
    tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    location = tenant.locations.create!(name: "Downtown", key: "downtown", alert_email: "downtown@pizza.example")
    website = Website.create!(tenant: tenant, fallback_location: location, name: "Main website", allowed_domain: "pizza.example", tracking_key: "pk_test_northstar")
    payload = {
      tracking_key: website.tracking_key,
      idempotency_key: "form-catering-900",
      lead_type: "catering",
      occurred_at: Time.current.iso8601,
      name: "  Alex Rivera ",
      email: " ALEX@Example.com ",
      phone: "+1 (604) 555-0199",
      message: "Lunch for 35 people",
      location_key: "downtown",
      source: "website_form",
      page_url: "https://pizza.example/catering",
      estimated_value: "850.00",
      email_consent: true,
      consent_source: "catering_form",
      consent_timestamp: Time.current.iso8601
    }

    assert_difference -> { Lead.count }, 1 do
      assert_difference -> { Contact.count }, 1 do
        assert_difference -> { Notification.count }, 1 do
          post v1_leads_path, params: payload, as: :json
          assert_response :created

          post v1_leads_path, params: payload, as: :json
          assert_response :success
          assert_equal true, response.parsed_body["duplicate"]
        end
      end
    end

    lead = Lead.find_by!(idempotency_key: "form-catering-900")
    assert_equal "alex@example.com", lead.contact.email
    assert_equal "+16045550199", lead.contact.phone
    assert_equal location, lead.location
    assert_equal 1, lead.histories.count
  end
end
