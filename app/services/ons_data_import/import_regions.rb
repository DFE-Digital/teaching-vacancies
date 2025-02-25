class OnsDataImport::ImportRegions < OnsDataImport::Base
  class << self
    def call
      super(api_name: "regions",
            name_field: "GOR10NM",
            valid_locations: DOWNCASE_ONS_REGIONS)
    end
  end
end
