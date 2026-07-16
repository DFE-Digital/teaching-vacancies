class ImportPolygonDataJob < SidekiqJob
  queue_as :low

  def perform
    load_data_set("cities") { |tolerance| OnsDataImport::ImportCities.call(tolerance) }
    load_data_set("counties") { |tolerance| OnsDataImport::ImportCounties.call(tolerance * 2) }
    load_data_set("regions") { |tolerance| OnsDataImport::ImportRegions.call(tolerance * 2) }
    load_data_set("composites") { |tolerance| OnsDataImport::CreateComposites.call(tolerance * 3) }
  end

  def load_data_set name, &block
    (0..).each do |tolerance_multiplier|
      tolerance = OnsDataImport::Base::TOLERANCE_100M + (tolerance_multiplier / 10_000.0)

      block.call(tolerance)

      invalid_names = LocationPolygon.order(:name).reject { |p|
        begin
          p.area.invalid_reason.nil? && p.uk_area.invalid_reason.nil?
        rescue StandardError
          false
        end
      }.map(&:name)

      if invalid_names.empty?
        logger.info "Loading #{name} tolerance #{tolerance_multiplier} (#{tolerance})"
        break
      else
        logger.info "Loading #{name} Invalid names #{invalid_names} for tolerance #{tolerance_multiplier} (#{tolerance})"
      end
    end
  end
end
