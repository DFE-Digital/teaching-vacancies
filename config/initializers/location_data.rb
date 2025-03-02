base_path = Rails.root.join("config/data/ons_mappings")

# ONS API config
ons_cities = YAML.load_file(base_path.join("ons_cities.yml"))
ons_counties_and_unitary_authorities = YAML.load_file(base_path.join("ons_counties_and_unitary_authorities.yml"))
ons_regions = YAML.load_file(base_path.join("ons_regions.yml"))

DOWNCASE_ONS_CITIES = ons_cities.map { |c| c.first.downcase }.freeze
DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES = ons_counties_and_unitary_authorities.map { |c| c.first.downcase }.freeze
DOWNCASE_ONS_REGIONS = ons_regions.map { |r| r.first.downcase }.freeze

composite_locations = YAML.load_file(base_path.join("composite_locations.yml")).freeze
DOWNCASE_COMPOSITE_LOCATIONS = composite_locations.transform_keys(&:downcase).freeze

ALL_IMPORTED_LOCATIONS =
  (DOWNCASE_ONS_REGIONS + DOWNCASE_COMPOSITE_LOCATIONS.keys + DOWNCASE_ONS_COUNTIES_AND_UNITARY_AUTHORITIES + DOWNCASE_ONS_CITIES).uniq.freeze

# Map from a user-inputted search term to a location polygon's name.
# We also need to map landing page location params to the location polygon's name, since these are `#parameterize`d in
# the routes and `#titleize`d in VacanciesController, but those operations are not symmetrical.
# Some of these basic mappings are overwritten in mapped_locations.yml, e.g. "manchester": "greater manchester".
# See also documentation/team/business-analyst-activities.md
landing_page_location_params_mapping = ALL_IMPORTED_LOCATIONS.to_h { |location| [location.parameterize.titleize.downcase, location] }
mapped_locations_from_file = YAML.load_file(base_path.join("mapped_locations.yml"))
MAPPED_LOCATIONS = landing_page_location_params_mapping.merge(mapped_locations_from_file)

# Locations with the location type from a human point of view for VacancyFacets
LOCATIONS_MAPPED_TO_HUMAN_FRIENDLY_TYPES = [
  ons_regions,
  ons_counties_and_unitary_authorities,
  ons_cities,
].inject(&:merge).transform_keys(&:downcase).freeze

ons_counties = ons_counties_and_unitary_authorities.select { |_k, v| v == "counties" }.map(&:first)
COUNTIES = (composite_locations.keys + ons_counties).reject do |county|
  # Reject duplicates caused by mapping locations, e.g. use Telford & Wrekin instead of Telford as location facets, rather than both.
  mapped_locations_from_file.include?(county.downcase)
end

ons_region_cities = ons_regions.select { |_k, v| v == "cities" }.map(&:first)
ons_unitary_authority_cities = ons_counties_and_unitary_authorities.select { |_k, v| v == "cities" }.map(&:first)
CITIES = (ons_cities.map(&:first) + ons_region_cities + ons_unitary_authority_cities).reject do |city|
  # Reject duplicates caused by mapping locations, e.g. use Telford & Wrekin instead of Telford as location facets, rather than both.
  mapped_locations_from_file.include?(city.downcase)
end

REDIRECTED_LOCATION_LANDING_PAGES = YAML.load_file("config/data/redirected_location_landing_pages.yml").freeze
