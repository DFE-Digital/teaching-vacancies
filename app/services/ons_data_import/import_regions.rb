module OnsDataImport
  class ImportRegions
    class << self
      def call
        Import.call(api_name: "Regions_December_2025_Boundaries_EN_BSC",
                    name_field: "RGN25NM",
                    valid_locations: DOWNCASE_ONS_REGIONS, tolerance: OnsDataImport::Import::SIMPLIFICATION_TOLERANCE)
      end
    end
  end
end
