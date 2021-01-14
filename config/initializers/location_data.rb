base_path = Rails.root.join("lib/tasks/data")

REGIONS = YAML.load_file(base_path.join("regions.yml"))
COUNTIES = YAML.load_file(base_path.join("counties.yml")).map { |line| line.keys.first }
BOROUGHS = YAML.load_file(base_path.join("boroughs.yml"))
CITIES = YAML.load_file(base_path.join("cities.yml"))

DOWNCASE_REGIONS = REGIONS.map(&:downcase)
DOWNCASE_COUNTIES = COUNTIES.map(&:downcase)
DOWNCASE_BOROUGHS = BOROUGHS.map(&:downcase)
DOWNCASE_CITIES = CITIES.map(&:downcase)

ALL_LOCATION_CATEGORIES = (DOWNCASE_REGIONS + DOWNCASE_COUNTIES + DOWNCASE_BOROUGHS + DOWNCASE_CITIES)

# ESMARspQHYMw9BZ9 is not an API key

LOCATION_POLYGON_SETTINGS = {
  regions: {
    boundary_api: "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/regions/FeatureServer/0/query?where=1%3D1&outFields=GOR10NM&outSR=4326&f=json",
    name_key: "GOR10NM",
  },
  counties: {
    boundary_api: "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Counties_and_Unitary_Authorities_April_2019_EW_BUC_v2/FeatureServer/0/query?where=1%3D1&outFields=ctyua19nm&outSR=4326&f=json",
    name_key: "CTYUA19NM",
  },
  london_boroughs: {
    boundary_api: "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Counties_and_Unitary_Authorities_April_2019_EW_BUC_v2/FeatureServer/0/query?where=1%3D1&outFields=ctyua19nm&outSR=4326&f=json",
    name_key: "CTYUA19NM",
  },
  cities: {
    boundary_api: "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Major_Towns_and_Cities_December_2015_EW_BGG/FeatureServer/0/query?where=1%3D1&outFields=tcity15nm,shape&outSR=4326&f=json",
    name_key: "TCITY15NM",
  },
}.freeze

DOWNCASE_COUNTIES_WITH_RING_INDICES = YAML.load_file(base_path.join("counties.yml")).map { |line|
  { line.keys.first.downcase.to_s => line.values.first }
}.inject(&:merge)
MAPPED_LOCATIONS = YAML.load_file(base_path.join("mapped_locations.yml")).to_h
