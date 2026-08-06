class ImportPolygonDataJob < SolidQueueJob
  queue_as :low

  def perform
    # Import composites first (including their constituents)
    OnsDataImport::CreateComposites.call
    OnsDataImport::ImportCounties.call
    OnsDataImport::ImportCities.call
    OnsDataImport::ImportRegions.call
  end
end
