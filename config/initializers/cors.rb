# https://github.com/cyu/rack-cors
Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: Rails.env.test?, logger: (-> { Rails.logger }) do
  allow do
    # Allow all domains access to jobs API
    origins "*"

    resource "/api/v1/jobs/*",
             headers: :any,
             methods: :get
  end

  allow do
    # Only allow our domains access to location suggestions API with HTTP GET
    origins Rails.application.config.allowed_cors_origin.call

    resource "/api/v1/location_suggestion/*",
             headers: :any,
             methods: :get

    resource "/api/v1/markers/*",
             headers: :any,
             methods: :get
  end
end
