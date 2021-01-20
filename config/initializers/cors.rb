# https://github.com/cyu/rack-cors
Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: Rails.env.test?, logger: (-> { Rails.logger }) do
  allow do
    # Allow all domains access to jobs API
    origins "*"

    resource "/api/v1/jobs/*",
             headers: :any,
             methods: :get
  end
end
