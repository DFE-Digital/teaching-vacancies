class ImportPolygonDataJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    %i[regions counties cities].each { |api_location_type| ImportPolygons.new(api_location_type: api_location_type).call }
  end
end
