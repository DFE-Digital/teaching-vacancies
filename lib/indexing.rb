require 'google/apis/indexing_v3'

class Indexing
  ACTIONS = { update: 'URL_UPDATED',
              remove: 'URL_DELETED' }.freeze

  API = Google::Apis::IndexingV3

  attr_reader :service, :url

  def initialize(url)
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
    notification = API::UrlNotification.new(url: url, type: ACTIONS[action])
    service.publish_url_notification(notification)
  end
end
