module OnsDataImport
  class ImportCounties
    class << self
      # The name field alters with the data set chosen -
      # see https://services1.arcgis.com/ESMARspQHYMw9BZ9/ArcGIS/rest/services/Counties_and_Unitary_Authorities_December_2025_Boundaries_UK_BSC/FeatureServer/0
      def call(tolerance: OnsDataImport::Import::SIMPLIFICATION_TOLERANCE, valid_locations: DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES)
        Import.call(api_name: "Counties_and_Unitary_Authorities_December_2025_Boundaries_UK_BSC",
                    name_field: "CTYUA25NM",
                    valid_locations: DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES & valid_locations, tolerance: tolerance)
      end
    end
  end
end
