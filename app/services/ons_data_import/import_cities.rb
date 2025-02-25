class OnsDataImport::ImportCities < OnsDataImport::Base
  class << self
    def call
      super(api_name: "Major_Towns_and_Cities_December_2015_Boundaries",
            name_field: "TCITY15NM",
            valid_locations: DOWNCASE_ONS_CITIES)
    end
  end
end
