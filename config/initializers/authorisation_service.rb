AUTHORISATION_SERVICE_URL = ENV['AUTHORISATION_SERVICE_URL']
AUTHORISATION_SERVICE_TOKEN = ENV['AUTHORISATION_SERVICE_TOKEN']

if AUTHORISATION_SERVICE_URL.nil?
  Rails.logger.error('***No authorisation service url configured. To configure set AUTHORISATION_SERVICE_URL')
end

if AUTHORISATION_SERVICE_TOKEN.nil?
  Rails.logger.error('***No authorisation service token configured. To configure set AUTHORISATION_SERVICE_TOKEN')
end
