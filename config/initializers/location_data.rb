base_path = Rails.root.join('lib/tasks/data')

REGIONS = YAML.load_file(base_path.join('regions.yml'))
COUNTIES = YAML.load_file(base_path.join('counties.yml'))
BOROUGHS = YAML.load_file(base_path.join('boroughs.yml'))
CITIES = YAML.load_file(base_path.join('cities.yml'))

DOWNCASE_REGIONS = REGIONS.map(&:downcase)
DOWNCASE_COUNTIES = COUNTIES.map(&:downcase)
DOWNCASE_BOROUGHS = BOROUGHS.map(&:downcase)
DOWNCASE_CITIES = CITIES.map(&:downcase)

ALL_LOCATION_CATEGORIES = (DOWNCASE_REGIONS + DOWNCASE_COUNTIES + DOWNCASE_BOROUGHS + DOWNCASE_CITIES)

LOCATION_POLYGON_SETTINGS = {
  regions: {
    api: 'https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Regions_December_2019_Boundaries_EN_BUC/MapServer/0/query?where=1%3D1&outFields=rgn19nm,shape&outSR=4326&f=json',
    name_key: 'rgn19nm'
  },
  counties: {
    api: 'https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Counties_and_Unitary_Authorities_April_2019_Boundaries_UK_BUC/MapServer/0/query?where=1%3D1&outFields=ctyua19nm,shape&outSR=4326&f=json',
    name_key: 'ctyua19nm'
  },
  london_boroughs: {
    api: 'https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Counties_and_Unitary_Authorities_April_2019_Boundaries_UK_BUC/MapServer/0/query?where=1%3D1&outFields=ctyua19nm,shape&outSR=4326&f=json',
    name_key: 'ctyua19nm'
  },
  cities: {
    api: 'https://ons-inspire.esriuk.com/arcgis/rest/services/Other_Boundaries/Major_Towns_and_Cities_December_2015_Boundaries_V2/MapServer/0/query?where=1%3D1&outFields=tcity15nm,shape&outSR=4326&f=json',
    name_key: 'tcity15nm'
  }
}.freeze
