base_path = Rails.root.join("lib/tasks/data")

# ONS API config
ons_cities = YAML.load_file(base_path.join("cities.yml"))
ons_counties_and_unitary_authorities = YAML.load_file(base_path.join("counties_and_unitary_authorities.yml"))
ons_regions = YAML.load_file(base_path.join("regions.yml"))

DOWNCASE_ONS_CITIES = ons_cities.map(&:downcase).freeze
DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES = ons_counties_and_unitary_authorities.map(&:first).map(&:downcase).freeze
DOWNCASE_ONS_REGIONS = ons_regions.map(&:first).map(&:downcase).freeze

composite_locations = YAML.load_file(base_path.join("composite_locations.yml")).freeze
DOWNCASE_COMPOSITE_LOCATIONS = composite_locations.transform_keys(&:downcase).freeze

ALL_LOCATION_CATEGORIES =
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

DOWNCASE_COUNTIES_WITH_RING_INDICES = YAML.load_file(base_path.join("counties_and_unitary_authorities.yml")).map { |line|
  { line.first.downcase => line.second }
}.inject(&:merge).freeze

# Locations with the location type from a human point of view for VacancyFacets
ons_regions_with_human_friendly_location_types = ons_regions.map { |line|
  { line.first.downcase => line.second }
}.inject(&:merge)
ons_counties_and_unitary_authorities_with_human_friendly_location_types = ons_counties_and_unitary_authorities.map { |line|
  { line.first.downcase => line.third }
}.inject(&:merge)
LOCATIONS_WITH_MAPPING_TO_HUMAN_FRIENDLY_LOCATION_TYPES = ons_counties_and_unitary_authorities_with_human_friendly_location_types
                                                            .merge(ons_regions_with_human_friendly_location_types).freeze

# Locations, as categorized by humans, for VacancyFacets
ons_counties = ons_counties_and_unitary_authorities.select { |line| line.third == "counties" }.map(&:first)
COUNTIES = composite_locations.keys + ons_counties
ons_unitary_authority_cities = ons_counties_and_unitary_authorities.select { |line| line.third == "cities" }.map(&:first)
CITIES = ons_cities + ons_unitary_authority_cities

# See documentation/business-analyst-activities.md
MAPPED_LOCATIONS = YAML.load_file(base_path.join("mapped_locations.yml")).to_h
