class Zendesk
  def self.create_request!(**kwargs)
    new(as: kwargs[:email_address]).create_request!(**kwargs)
  end

  def initialize(as:)
    raise ConfigurationError, "Please set ZENDESK_API_KEY for this environment." if api_key.blank?

    @as = as
  end

  def create_request!(name:, email_address:, subject:, comment:, attachments: [])
    client.requests.create!(
      comment: {
        body: comment,
        uploads: attachments.reject(&:blank?).map { |a| client.uploads.create!(file: a).id },
      },
      requester: {
        name:,
        email: email_address,
      },
      subject: "[Support request] #{subject}",
    )
  end

  private

  def client
    # https://github.com/zendesk/zendesk_api_client_rb#configuration
    @client ||= ZendeskAPI::Client.new do |config|
      config.url = "https://teachingjobs.zendesk.com/api/v2"

      # "When using an API token to create requests on behalf of end users,
      # use the end user's email address and not an agent's email address"
      #
      # https://developer.zendesk.com/api-reference/ticketing/tickets/ticket-requests/#api-token
      config.username = @as
      config.token = api_key
    end
  end

  def api_key
    @api_key ||= ENV["ZENDESK_API_KEY"]
  end

  class ConfigurationError < StandardError; end
end
