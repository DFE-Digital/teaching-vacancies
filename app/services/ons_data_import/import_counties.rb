class OnsDataImport::ImportCounties < OnsDataImport::Base
  def api_name
    "Counties_and_Unitary_Authorities_April_2019_Boundaries_EW_BUC_2022"
  end

  def name_field
    "CTYUA19NM"
  end

  def in_scope?(location_name)
    DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES.include?(location_name)
  end
end
