class ImportPolygonDataJob < ApplicationJob
  queue_as :import_polygon_data

  def perform
    return if DisableExpensiveJobs.enabled?

    %i[regions counties cities].each { |location_type| ImportPolygons.new(location_type: location_type).call }
  end
end
