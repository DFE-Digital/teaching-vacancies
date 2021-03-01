base_path = Rails.root.join("lib/tasks/data")

# ONS API config
ons_cities = YAML.load_file(base_path.join("ons_cities.yml"))
ons_counties_and_unitary_authorities = YAML.load_file(base_path.join("ons_counties_and_unitary_authorities.yml"))
ons_regions = YAML.load_file(base_path.join("ons_regions.yml"))

DOWNCASE_ONS_CITIES = ons_cities.map(&:first).map(&:downcase).freeze
DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES = ons_counties_and_unitary_authorities.map(&:first).map(&:downcase).freeze
DOWNCASE_ONS_REGIONS = ons_regions.map(&:first).map(&:downcase).freeze

composite_locations = YAML.load_file(base_path.join("composite_locations.yml")).freeze
DOWNCASE_COMPOSITE_LOCATIONS = composite_locations.transform_keys(&:downcase).freeze

ALL_IMPORTED_LOCATIONS =
  (DOWNCASE_ONS_REGIONS + DOWNCASE_COMPOSITE_LOCATIONS.keys + DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES + DOWNCASE_ONS_CITIES).uniq.freeze

LOCATION_POLYGON_SETTINGS = { # ESMARspQHYMw9BZ9 is not an API key
  regions: {
    boundary_api: "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/regions/FeatureServer/0/query?where=1%3D1&outFields=GOR10NM&outSR=4326&f=json",
    name_key: "GOR10NM",
  },
  counties: {
    boundary_api: "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Counties_and_Unitary_Authorities_April_2019_EW_BUC_v2/FeatureServer/0/query?where=1%3D1&outFields=ctyua19nm&outSR=4326&f=json",
    name_key: "CTYUA19NM",
  },
  cities: {
    boundary_api: "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Major_Towns_and_Cities_December_2015_EW_BGG/FeatureServer/0/query?where=1%3D1&outFields=tcity15nm,shape&outSR=4326&f=json",
    name_key: "TCITY15NM",
  },
}.freeze

# See documentation/business-analyst-activities.md
MAPPED_LOCATIONS = YAML.load_file(base_path.join("mapped_locations.yml")).to_h

# Locations with the location type from a human point of view for VacancyFacets
LOCATIONS_MAPPED_TO_HUMAN_FRIENDLY_TYPES = [ons_regions, ons_counties_and_unitary_authorities, ons_cities].map { |file|
  file.to_h.transform_keys(&:downcase)
}.inject(&:merge).freeze

ons_counties = ons_counties_and_unitary_authorities.select { |line| line.second == "counties" }.map(&:first)
COUNTIES = (composite_locations.keys + ons_counties).reject do |county|
  # Reject duplicates caused by mapping locations, e.g. use Telford & Wrekin instead of Telford as location facets, rather than both.
  MAPPED_LOCATIONS.include?(county.downcase)
end

ons_unitary_authority_cities = ons_counties_and_unitary_authorities.select { |line| line.second == "cities" }.map(&:first)
CITIES = (ons_cities.map(&:first) + ons_unitary_authority_cities).reject do |city|
  # Reject duplicates caused by mapping locations, e.g. use Telford & Wrekin instead of Telford as location facets, rather than both.
  MAPPED_LOCATIONS.include?(city.downcase)
end
