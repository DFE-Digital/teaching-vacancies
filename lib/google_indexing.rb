require "google/apis/indexing_v3"

class GoogleIndexing
  ACTIONS = { update: "URL_UPDATED",
              remove: "URL_DELETED" }.freeze

  API = Google::Apis::IndexingV3

  attr_reader :service, :url

  def initialize(url)
    @api_client = GoogleApiClient.instance
    return if @api_client.missing_key?

    @service = API::IndexingService.new
    @service.authorization = api_client.authorization
    @url = url
  end

  def update
    call(:update)
  end

  def remove
    call(:remove)
  end

  private

  attr_reader :api_client

  def call(action)
    return if api_client.missing_key?

    notification = API::UrlNotification.new(url: url, type: ACTIONS[action])
    service.publish_url_notification(notification)
  end
end
