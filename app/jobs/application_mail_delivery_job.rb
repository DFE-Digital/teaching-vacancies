require "openssl"

class ApplicationMailDeliveryJob < ActionMailer::MailDeliveryJob
  # Transient TLS/SSL failures (e.g. "SSL_read: (null) (tls_retry_write_records
  # failure)") happen intermittently when talking to the SMTP/Notify endpoints.
  # Retry rather than dumping the email into the failed jobs dashboard.
  retry_on OpenSSL::SSL::SSLError, wait: :polynomially_longer, attempts: 5
end
