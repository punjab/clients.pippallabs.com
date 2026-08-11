demo_password = "pippal-demo-2026"
demo_key = "pk_demo_northstar_local"

tenant = Tenant.find_or_initialize_by(slug: "northstar-pizza")
tenant.assign_attributes(name: "Northstar Pizza Co.", time_zone: "America/Vancouver", default_location_key: "downtown", notification_email: "leads@northstar.test")
tenant.save!

locations = [
  [ "Downtown", "downtown", "downtown@northstar.test" ],
  [ "Kitsilano", "kitsilano", "kits@northstar.test" ],
  [ "Burnaby Heights", "burnaby-heights", "burnaby@northstar.test" ]
].map do |name, key, email|
  tenant.locations.find_or_create_by!(key:) { |location| location.assign_attributes(name:, alert_email: email) }
end

website = tenant.websites.find_or_initialize_by(allowed_domain: "northstar-pizza.test")
if website.new_record?
  website.assign_attributes(name: "Northstar main site", fallback_location: locations.first, tracking_key: demo_key)
  website.save!
end

people = [
  [ "Asha Kapoor", "agency@pippallabs.test", :agency_admin, nil ],
  [ "Priya Shah", "owner@northstar.test", :client_owner, nil ],
  [ "Maya Chen", "manager@northstar.test", :location_manager, locations.first ],
  [ "Noah Williams", "viewer@northstar.test", :viewer, nil ]
].map do |name, email, role, location|
  user = User.find_or_initialize_by(email_address: email)
  user.assign_attributes(name:, password: demo_password) if user.new_record?
  user.save!
  tenant.memberships.find_or_create_by!(user:) { |membership| membership.assign_attributes(role:, location:) }
  [ role, user ]
end.to_h

sources = %w[google google google direct instagram newsletter]
pages = %w[/ /menu /catering /locations /coupons]
now = Time.current

30.times do |day|
  (3 + day % 5).times do |visit_number|
    session_id = "demo-#{day}-#{visit_number}"
    occurred_at = (now - day.days).change(hour: 11 + visit_number % 6, min: visit_number * 7)
    location = locations[(day + visit_number) % locations.length]
    source = sources[(day * 2 + visit_number) % sources.length]
    page = pages[(day + visit_number) % pages.length]
    attributes = {
      tenant:, website:, location:, occurred_at:, accepted_at: occurred_at + 1.second,
      session_id:, landing_page: "https://northstar-pizza.test#{page}", referrer: source == "google" ? "https://google.com" : "unknown",
      utm_source: source, request_id: "seed-#{day}-#{visit_number}", metadata: {}
    }
    Event.find_or_create_by!(tenant:, event_id: "pv-#{day}-#{visit_number}") { |event| event.assign_attributes(**attributes, event_type: "page_view", page_url: "https://northstar-pizza.test#{page}") }
    if visit_number.even?
      event_type = visit_number % 4 == 0 ? "order_click" : "call_click"
      Event.find_or_create_by!(tenant:, event_id: "intent-#{day}-#{visit_number}") do |event|
        event.assign_attributes(**attributes, event_type:, page_url: "https://northstar-pizza.test#{page}", metadata: { target_url: event_type == "call_click" ? "https://northstar-pizza.test/locations" : "https://northstar-pizza.test/order" })
      end
    end
  end
end

lead_data = [
  [ "Elena Rossi", "elena@example.test", "catering", :new, 0, 1_400, nil, nil, "Wedding rehearsal dinner for 55 guests." ],
  [ "Marcus Lee", "marcus@example.test", "event", :contacted, 1, 780, nil, nil, "Team lunch next Thursday, approximately 30 people." ],
  [ "Sofia Patel", "sofia@example.test", "catering", :quoted, 3, 2_250, nil, nil, "School fundraiser with delivery to two buildings." ],
  [ "Daniel Kim", "daniel@example.test", "general", :won, 7, 620, 595, nil, "Birthday party package for 22." ],
  [ "Amara Johnson", "amara@example.test", "catering", :lost, 10, 1_800, nil, "Date unavailable", "Corporate reception requiring a staffed service." ],
  [ "Theo Martin", "theo@example.test", "franchise", :contacted, 14, 0, nil, nil, "Interested in franchise information." ],
  [ "Nina García", "nina@example.test", "event", :won, 18, 1_050, 1_120, nil, "Community centre volunteer dinner." ],
  [ "Bot Submission", "bot@example.test", "general", :spam, 20, 0, nil, nil, "Buy links now." ]
]

lead_data.each_with_index do |(name, email, type, status, days_ago, estimate, actual, lost_reason, message), index|
  contact = tenant.contacts.find_or_create_by!(email:) { |record| record.name = name }
  lead = tenant.leads.find_or_initialize_by(idempotency_key: "seed-lead-#{index}")
  if lead.new_record?
    occurred_at = now - days_ago.days
    lead.assign_attributes(
      website:, contact:, location: locations[index % locations.length], owner: index.zero? ? nil : people[:location_manager],
      lead_type: type, status:, occurred_at:, message:, source: sources[index % sources.length],
      page_url: "https://northstar-pizza.test/#{type}", estimated_value: estimate, actual_value: actual,
      lost_reason:, closed_at: Lead::TERMINAL_STATUSES.include?(status.to_s) ? occurred_at + 1.day : nil,
      follow_up_at: Lead::ACTIVE_STATUSES.include?(status.to_s) ? (index.even? ? 1.day.ago : 2.days.from_now) : nil,
      request_id: "seed-lead-request-#{index}"
    )
    lead.save!
    lead.histories.create!(tenant:, change_type: "created", to_status: "new", occurred_at: occurred_at)
    if status.to_s != "new"
      lead.histories.create!(tenant:, actor: people[:location_manager], change_type: "status_changed", from_status: "new", to_status: status, occurred_at: occurred_at + 2.hours)
    end
  end
end

ReportGenerator.call(tenant:, period_start: Date.current.beginning_of_month, period_end: Date.current.end_of_month)
ReportGenerator.call(tenant:, period_start: 1.month.ago.to_date.beginning_of_month, period_end: 1.month.ago.to_date.end_of_month)

puts "Seeded Northstar Pizza Co."
puts "Login: agency@pippallabs.test / #{demo_password}"
puts "Client owner: owner@northstar.test / #{demo_password}"
puts "Location manager: manager@northstar.test / #{demo_password}"
puts "Demo tracking key: #{demo_key}"
