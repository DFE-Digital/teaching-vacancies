class ImportPolygonDataJob < SidekiqJob
  queue_as :low

  def perform
    (0..).each do |tolerance_multiplier|
      tolerance = OnsDataImport::Base::TOLERANCE_100M + (tolerance_multiplier / 10000.0)
      OnsDataImport::ImportCounties.call(tolerance)
      OnsDataImport::ImportCities.call(tolerance)
      OnsDataImport::ImportRegions.call(tolerance)
      OnsDataImport::CreateComposites.call(tolerance)

      invalid_names = LocationPolygon.all.order(:name).reject { |p| p.area.invalid_reason.nil? && p.uk_area.invalid_reason.nil? rescue false }.map(&:name)

      break if invalid_names.empty?
      logger.info "Invalid names #{invalid_names} for tolerance #{tolerance_multiplier} (#{tolerance})"
    end
  end
end
