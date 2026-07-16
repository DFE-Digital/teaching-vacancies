class OnsDataImport::ImportCounties < OnsDataImport::Base
  class << self
    def call(tolerance)
      super(api_name: "Counties_and_Unitary_Authorities_April_2019_Boundaries_EW_BFC_2022",
            name_field: "CTYUA19NM",
            valid_locations: DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES, tolerance: tolerance)
    end
  end
end
