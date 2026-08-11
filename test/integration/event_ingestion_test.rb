require "test_helper"

class EventIngestionTest < ActionDispatch::IntegrationTest
  test "retrying an event id does not double count it" do
    tenant = Tenant.create!(name: "Northstar Pizza", slug: "northstar")
    website = Website.create!(tenant: tenant, name: "Main website", allowed_domain: "pizza.example", tracking_key: "pk_test_northstar")
    payload = {
      tracking_key: website.tracking_key,
      event_id: "evt-order-100",
      event_type: "order_click",
      occurred_at: Time.current.iso8601,
      session_id: "session-42",
      page_url: "https://pizza.example/menu",
      landing_page: "https://pizza.example/summer",
      referrer: "https://www.google.com/",
      utm_source: "google",
      metadata: { target_url: "https://order.example/start" }
    }

    assert_difference -> { Event.count }, 1 do
      post v1_events_path, params: payload, as: :json
      assert_response :accepted

      post v1_events_path, params: payload, as: :json
      assert_response :success
      assert_equal true, response.parsed_body["duplicate"]
    end

    event = Event.find_by!(event_id: "evt-order-100")
    assert_equal tenant.id, event.tenant_id
    assert_equal "google", event.utm_source
  end
end
