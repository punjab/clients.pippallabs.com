demo_password = "pippal-demo-2026"
demo_key = "pk_demo_curry_local"

tenant = Tenant.find_by(slug: "curry-pizza-company") || Tenant.find_by(slug: "northstar-pizza") || Tenant.new
tenant.assign_attributes(name: "Curry Pizza Company", slug: "curry-pizza-company", time_zone: "America/Vancouver", default_location_key: "downtown", notification_email: "leads@currypizzacompany.test")
tenant.save!

locations = [
  [ "Downtown", "downtown", "downtown@currypizzacompany.test" ],
  [ "Kitsilano", "kitsilano", "kits@currypizzacompany.test" ],
  [ "Burnaby Heights", "burnaby-heights", "burnaby@currypizzacompany.test" ]
].map do |name, key, email|
  tenant.locations.find_or_initialize_by(key:).tap { |location| location.update!(name:, alert_email: email) }
end

website = tenant.websites.find_by(allowed_domain: "currypizzacompany.test") || tenant.websites.find_by(allowed_domain: "northstar-pizza.test") || tenant.websites.new
website.assign_attributes(name: "Curry Pizza Company main site", allowed_domain: "currypizzacompany.test", fallback_location: locations.first, tracking_key: demo_key)
website.save!

people = [
  [ "Asha Kapoor", "agency@pippallabs.test", :super_admin, nil ],
  [ "Priya Shah", "owner@currypizzacompany.test", :client_owner, nil ],
  [ "Maya Chen", "manager@currypizzacompany.test", :location_manager, locations.first ],
  [ "Noah Williams", "viewer@currypizzacompany.test", :viewer, nil ]
].map do |name, email, role, location|
  legacy_email = email.sub("@currypizzacompany.test", "@northstar.test")
  user = User.find_by(email_address: email) || User.find_by(email_address: legacy_email) || User.new
  user.assign_attributes(name:, email_address: email, password: demo_password, super_admin: role == :super_admin)
  user.save!
  if role == :super_admin
    user.memberships.destroy_all
  else
    tenant.memberships.find_or_initialize_by(user:).tap { |membership| membership.update!(role:, location:) }
  end
  [ role, user ]
end.to_h

sources = %w[google google google direct instagram newsletter]
pages = %w[/ /menu /catering /locations /coupons]
now = Time.current

30.times do |day|
  (3 + day % 5).times do |visit_number|
    session_id = "demo-#{day}-#{visit_number}"
    occurred_at = [ (now - day.days).change(hour: 11 + visit_number % 6, min: visit_number * 7), now ].min
    location = locations[(day + visit_number) % locations.length]
    source = sources[(day * 2 + visit_number) % sources.length]
    page = pages[(day + visit_number) % pages.length]
    attributes = {
      tenant:, website:, location:, occurred_at:, accepted_at: occurred_at + 1.second,
      session_id:, landing_page: "https://currypizzacompany.test#{page}", referrer: source == "google" ? "https://google.com" : "unknown",
      utm_source: source, request_id: "seed-#{day}-#{visit_number}", metadata: {}
    }
    Event.find_or_create_by!(tenant:, event_id: "pv-#{day}-#{visit_number}") { |event| event.assign_attributes(**attributes, event_type: "page_view", page_url: "https://currypizzacompany.test#{page}") }
    if visit_number.even?
      event_type = visit_number % 4 == 0 ? "order_click" : "call_click"
      Event.find_or_create_by!(tenant:, event_id: "intent-#{day}-#{visit_number}") do |event|
        event.assign_attributes(**attributes, event_type:, page_url: "https://currypizzacompany.test#{page}", metadata: { target_url: event_type == "call_click" ? "https://currypizzacompany.test/locations" : "https://currypizzacompany.test/order" })
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
      page_url: "https://currypizzacompany.test/#{type}", estimated_value: estimate, actual_value: actual,
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

tenant.workspace_features.find_or_initialize_by(key: "recruiting").update!(enabled: true)
kitchen_position = tenant.job_postings.find_or_initialize_by(key: "kitchen-team-member")
kitchen_position.update!(title: "Kitchen Team Member", location: locations.first, description: "Prepare food, support service, and create a welcoming guest experience.", status: :open)
counter_position = tenant.job_postings.find_or_initialize_by(key: "counter-team-member")
counter_position.update!(title: "Counter Team Member", location: locations.second, description: "Welcome guests, take orders, and keep service moving smoothly.", status: :open)

[
  [ kitchen_position, "Sam Lee", "sam.applicant@example.test", "Evenings and weekends", "Two years in a busy restaurant kitchen.", "I enjoy serving the local community." ],
  [ counter_position, "Jordan Singh", "jordan.applicant@example.test", "Weekdays after 3pm", "Customer service and cash-handling experience.", "Curry Pizza Company feels welcoming and energetic." ]
].each_with_index do |(position, name, email, availability, experience, motivation), index|
  JobApplicationIngestor.call(
    website:,
    request_id: "seed-application-request-#{index}",
    attributes: {
      idempotency_key: "seed-application-#{index}", position_key: position.key,
      occurred_at: now - index.days, name:, email:, availability:, experience:, motivation:,
      location_key: position.location.key, source: "careers_form",
      page_url: "https://currypizzacompany.test/careers", privacy_notice_version: "2026-08",
      future_opportunities_consent: index.positive?
    }
  )
end

ReportGenerator.call(tenant:, period_start: Date.current.beginning_of_month, period_end: Date.current.end_of_month)
ReportGenerator.call(tenant:, period_start: 1.month.ago.to_date.beginning_of_month, period_end: 1.month.ago.to_date.end_of_month)

puts "Seeded Curry Pizza Company"
puts "Login: agency@pippallabs.test / #{demo_password}"
puts "Client owner: owner@currypizzacompany.test / #{demo_password}"
puts "Location manager: manager@currypizzacompany.test / #{demo_password}"
puts "Demo tracking key: #{demo_key}"
