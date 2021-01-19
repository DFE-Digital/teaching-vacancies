class ImportPolygonDataJob < ApplicationJob
  queue_as :import_polygon_data

  def perform
    return if DisableExpensiveJobs.enabled?

    %i[regions counties cities].each { |api_location_type| ImportPolygons.new(api_location_type: api_location_type).call }
  end
end
