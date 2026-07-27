# Retry transient SSL/TLS errors when delivering email instead of letting the
# job land in the Solid Queue failed jobs dashboard for manual retry.

# All mailers deliver via ApplicationMailDeliveryJob, which retries OpenSSL errors.
# Set in a to_prepare block so the (autoloaded, reloadable) job constant is only
# referenced once autoloading is available — referencing it directly from an
# initializer autoloads too early and raises on boot.
require "openssl"

Rails.application.config.to_prepare do
  ActionMailer::Base.delivery_job = ApplicationMailDeliveryJob
end

# Noticed delivers email through its own job (Noticed::DeliveryMethods::Email),
# so give it the same retry behaviour.
ActiveSupport.on_load(:noticed_delivery_methods_email) do
  retry_on OpenSSL::SSL::SSLError, wait: :polynomially_longer, attempts: 5
end
