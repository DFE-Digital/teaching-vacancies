class OnsDataImport::ImportCities < OnsDataImport::Base
  class << self
    def call(tolerance: TOLERANCE_100M, valid_locations: DOWNCASE_ONS_CITIES)
      super(api_name: "Major_Towns_and_Cities_Dec_2015_Boundaries_V2_2022",
            # super(api_name: "Major_Towns_and_Cities_December_2015_Boundaries",
            name_field: "TCITY15NM",
            valid_locations: valid_locations, tolerance: tolerance)
    end
  end
end
