class OnsDataImport::ImportRegions < OnsDataImport::Base
  def location_type
    :regions
  end

  def api_name
    "regions"
  end

  def name_field
    "GOR10NM"
  end

  def in_scope?(location_name)
    DOWNCASE_ONS_REGIONS.include?(location_name)
  end
end
