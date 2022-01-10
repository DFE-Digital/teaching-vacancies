require "google/apis/indexing_v3"

class Indexing
  ACTIONS = { update: "URL_UPDATED",
              remove: "URL_DELETED" }.freeze

  API = Google::Apis::IndexingV3

  attr_reader :service, :url

  def initialize(url)
    return if api_key_empty?

    @service = API::IndexingService.new
    @url = url
  end

  def update
    call(:update)
  end

  def remove
    call(:remove)
  end

  private

  def call(action)
    notification = API::UrlNotification.new(url:, type: ACTIONS[action])
    service.publish_url_notification(notification)
  end

  def api_key_empty?
    GOOGLE_API_JSON_KEY.empty? || JSON.parse(GOOGLE_API_JSON_KEY).empty?
  end
end
