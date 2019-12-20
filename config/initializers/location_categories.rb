base_path = Rails.root.join('lib/tasks/data')

REGIONS = YAML.load_file(base_path.join('regions.yml'))
COUNTIES = YAML.load_file(base_path.join('counties.yml'))
BOROUGHS = YAML.load_file(base_path.join('boroughs.yml'))
CITIES = YAML.load_file(base_path.join('cities.yml'))

ALL_LOCATION_CATEGORIES = (REGIONS + COUNTIES + BOROUGHS + CITIES).map(&:downcase)
