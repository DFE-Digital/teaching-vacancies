class ImportPolygonDataJob < SidekiqJob
  queue_as :low

  def perform
    load_data_set("cities") { |tolerance| OnsDataImport::ImportCities.call(tolerance) }
    load_data_set("counties") { |tolerance| OnsDataImport::ImportCounties.call(tolerance) }
    load_data_set("composites") { |tolerance| OnsDataImport::CreateComposites.call(tolerance) }
    load_data_set("regions") { |tolerance| OnsDataImport::ImportRegions.call(tolerance * 3) }
  end

  def load_data_set name, &block
    (0..).each do |tolerance_multiplier|
      tolerance = OnsDataImport::Base::TOLERANCE_100M + (tolerance_multiplier / 10_000.0)

      newest_polygon = LocationPolygon.order(:updated_at).last

      block.call(tolerance)

      # only check polygons updated by the call
      invalid_names = LocationPolygon.where(updated_at: newest_polygon.updated_at..).order(:name).reject { |p|
        begin
          p.area.invalid_reason.nil? && p.uk_area.invalid_reason.nil?
        rescue StandardError
          false
        end
      }.map(&:name)

      if invalid_names.empty?
        logger.info "Loaded #{name} tolerance #{tolerance_multiplier} (#{tolerance})"
        break
      else
        logger.info "Loading #{name} Invalid names #{invalid_names} for tolerance #{tolerance_multiplier} (#{tolerance})"
      end
      # LocationPolygon.where(updated_at: newest_polygon.updated_at..).order(:name).each { |p|
      #   case p.area.invalid_reason
      #   when RGeo::Error::SELF_INTERSECTION
      #     p.area.make_valid
      #     p.save!
      #     break
      #   when nil
      #     break
      #   else
      #     p.area.check_validity!
      #   end
      #   case p.uk_area.invalid_reason
      #   when RGeo::Error::SELF_INTERSECTION
      #     p.uk_area.make_valid
      #     p.save!
      #     break
      #   when nil
      #     break
      #   else
      #     p.uk_area.check_validity!
      #   end
      # }
    end
  end
end
