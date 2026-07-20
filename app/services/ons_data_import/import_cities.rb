module OnsDataImport
  class ImportCities
    # This simpflication tolerance (about 120m) works for all cities in the current data set
    CITY_SIMPLIFICATION_TOLERANCE = 0.0012

    class << self
      def call(tolerance: CITY_SIMPLIFICATION_TOLERANCE, valid_locations: DOWNCASE_ONS_CITIES)
        Import.call(api_name: "Major_Towns_and_Cities_Dec_2015_Boundaries_V2_2022",
                    name_field: "TCITY15NM",
                    valid_locations: DOWNCASE_ONS_CITIES & valid_locations, tolerance: tolerance)
      end
    end
  end
end
