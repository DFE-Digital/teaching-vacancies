default_domains = {
  test: "localhost:3000",
  development: "localhost:3000",
  production: "teaching-vacancies.service.gov.uk",
}

DOMAIN = ENV.fetch("DOMAIN") { default_domains[Rails.env.to_sym] }
domain = URI(DOMAIN)
protocol = Rails.application.config.force_ssl ? "https" : "http"
url_options = { protocol:, host: domain.to_s }

Rails.configuration.action_mailer.default_url_options = url_options
Rails.application.routes.default_url_options = url_options
