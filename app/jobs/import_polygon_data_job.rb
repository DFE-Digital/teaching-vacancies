class ImportPolygonDataJob < SidekiqJob
  queue_as :low

  def perform
    load_data_set("composites") { |tolerance| OnsDataImport::CreateComposites.call(tolerance: tolerance) }
    load_data_set("cities") { |tolerance| OnsDataImport::ImportCities.call(tolerance: tolerance) }
    load_data_set("counties") { |tolerance| OnsDataImport::ImportCounties.call(tolerance: tolerance) }
    load_data_set("regions") { |tolerance| OnsDataImport::ImportRegions.call(tolerance * 2) }
  end

  def load_data_set(name)
    (0..).each do |tolerance_multiplier|
      tolerance = OnsDataImport::Base::TOLERANCE_100M + (tolerance_multiplier / 10_000.0)

      newest_polygon = LocationPolygon.order(:updated_at).last

      yield(tolerance)

      # only check polygons updated by the call
      changed_polygons = if newest_polygon.present?
                           LocationPolygon.where(updated_at: newest_polygon.updated_at..)
                         else
                           LocationPolygon.all
                         end
      invalid_names = changed_polygons.order(:name)
                                     .reject(&:area_data_valid?)
                                     .map(&:name)

      if invalid_names.empty?
        logger.info "Loaded #{name} tolerance #{tolerance_multiplier} (#{tolerance})"
        break
      else
        logger.info "Loading #{name} Invalid names #{invalid_names} for tolerance #{tolerance_multiplier} (#{tolerance})"
      end
    end
  end
end
