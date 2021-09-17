class ImportPolygonDataJob < ApplicationJob
  queue_as :low

  def perform
    OnsDataImport::ImportCounties.new.call
    OnsDataImport::ImportCities.new.call
    OnsDataImport::ImportRegions.new.call

    # TODO: Below is the legacy import code which can be removed once we have moved away from
    #       Algolia and the need for legacy polygon data
    return if DisableExpensiveJobs.enabled?

    %i[regions counties cities].each { |api_location_type| ImportPolygons.new(api_location_type: api_location_type).call }
  end
end
