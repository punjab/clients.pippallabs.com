Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"
    resource "/v1/events", headers: :any, methods: %i[post options], credentials: false, max_age: 600
  end
end
