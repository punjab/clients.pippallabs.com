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

  test "newsletter signup is accepted with consent and creates no alert" do
    tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    location = tenant.locations.create!(name: "Downtown", key: "downtown", alert_email: "downtown@pizza.example")
    website = Website.create!(tenant: tenant, fallback_location: location, name: "Main website", allowed_domain: "pizza.example", tracking_key: "pk_test_northstar")
    consent_timestamp = Time.current.iso8601
    payload = {
      tracking_key: website.tracking_key,
      idempotency_key: "newsletter-signup-100",
      lead_type: "newsletter",
      occurred_at: Time.current.iso8601,
      email: "subscriber@example.com",
      email_consent: true,
      consent_source: "newsletter_form",
      consent_timestamp: consent_timestamp
    }

    assert_difference -> { Lead.count }, 1 do
      assert_no_difference -> { Notification.count } do
        assert_no_enqueued_jobs only: LeadAlertJob do
          post v1_leads_path, params: payload, as: :json
          assert_response :created
        end
      end
    end

    lead = Lead.find_by!(idempotency_key: "newsletter-signup-100")
    assert_equal "newsletter", lead.lead_type
    assert_equal "subscriber@example.com", lead.contact.email
    assert_equal true, lead.contact.email_consent
    assert_equal "newsletter_form", lead.contact.email_consent_source
    assert_equal Time.iso8601(consent_timestamp), lead.contact.email_consent_at
    assert_equal 1, lead.histories.count
  end

  test "non-newsletter lead still creates an alert notification" do
    tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    location = tenant.locations.create!(name: "Downtown", key: "downtown", alert_email: "downtown@pizza.example")
    website = Website.create!(tenant: tenant, fallback_location: location, name: "Main website", allowed_domain: "pizza.example", tracking_key: "pk_test_northstar")
    payload = {
      tracking_key: website.tracking_key,
      idempotency_key: "form-general-901",
      lead_type: "general",
      occurred_at: Time.current.iso8601,
      email: "general@example.com",
      message: "Do you deliver to Burnaby?"
    }

    assert_difference -> { Notification.count }, 1 do
      assert_enqueued_jobs 1, only: LeadAlertJob do
        post v1_leads_path, params: payload, as: :json
        assert_response :created
      end
    end

    notification = Lead.find_by!(idempotency_key: "form-general-901").notifications.sole
    assert_equal "new_lead", notification.kind
    assert_equal "downtown@pizza.example", notification.recipient
  end
end
