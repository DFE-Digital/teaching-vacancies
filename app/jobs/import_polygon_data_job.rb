class ImportPolygonDataJob < ApplicationJob
  queue_as :import_polygon_data

  def perform
    return if DisableExpensiveJobs.enabled?

    %i[regions counties london_boroughs cities].each { |location| ImportPolygons.new(location_type: location).call }
  end
end
