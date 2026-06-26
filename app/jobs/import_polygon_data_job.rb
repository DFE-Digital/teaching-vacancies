class ImportPolygonDataJob < ApplicationJob
  queue_as :low

  def perform
    OnsDataImport::ImportCounties.call
    OnsDataImport::ImportCities.call
    OnsDataImport::ImportRegions.call
    OnsDataImport::CreateComposites.new.call
  end
end
