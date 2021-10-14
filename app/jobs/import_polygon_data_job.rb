class ImportPolygonDataJob < ApplicationJob
  queue_as :low

  def perform
    OnsDataImport::ImportCounties.new.call
    OnsDataImport::ImportCities.new.call
    OnsDataImport::ImportRegions.new.call
  end
end
