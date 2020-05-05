# Configure Rack::Cors https://github.com/cyu/rack-cors
Rails.application.config.middleware.insert_before 0, Rack::Cors, logger: (-> { Rails.logger }) do
  allow do
    # Allow all domains access to jobs API
    origins '*'

    resource '/api/v1/jobs/*',
      headers: :any,
      methods: [:get, :post, :delete, :put, :patch, :options, :head]
  end

  allow do
    # Only allow our domains access to coordinates API with HTTP GET
    origins Rails.application.config.allowed_cors_origin

    resource '/api/v1/coordinates/*',
      headers: :any,
      methods: :get
  end
end
