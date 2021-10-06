class OnsDataImport::ImportCities < OnsDataImport::Base
  def location_type
    :cities
  end

  def api_name
    "Major_Towns_and_Cities_December_2015_Boundaries"
  end

  def name_field
    "TCITY15NM"
  end

  def in_scope?(location_name)
    DOWNCASE_ONS_CITIES.include?(location_name)
  end
end
