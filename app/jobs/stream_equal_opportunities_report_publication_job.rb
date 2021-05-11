class StreamEqualOpportunitiesReportPublicationJob < ApplicationJob
  queue_as :low

  def perform
    Vacancy.expired_yesterday.listed.select(&:publish_equal_opportunities_report?).each do |vacancy|
      vacancy.equal_opportunities_report&.trigger_event
    end
  end
end
