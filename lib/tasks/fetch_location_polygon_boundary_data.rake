LOCATION_POLYGON_SETTINGS = {
  regions: {
    api: 'https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Regions_December_2019_Boundaries_EN_BFC/MapServer/0/query?where=1%3D1&outFields=rgn19nm,shape&outSR=4326&f=json',
    name_key: 'rgn19nm'
  },
  counties: {
    api: 'https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Counties_December_2019_Boundaries_EN_BFC/MapServer/0/query?where=1%3D1&outFields=cty19nm,shape&outSR=4326&f=json',
    name_key: 'cty19nm'
  },
  local_authorities: {
    api: 'https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Local_Authority_Districts_December_2019_Boundaries_UK_BFC/MapServer/0/query?where=1%3D1&outFields=lad19nm,shape&outSR=4326&f=json',
    name_key: 'lad19nm'
  }
}

namespace :data do
  desc 'Fetch location polygon boundary data from ONS'
  namespace :fetch_location_polygons_from_api do
    task regions: :environment do
      fetch_and_process_api(:regions)
    end

    task counties: :environment do
      fetch_and_process_api(:counties)
    end

    task local_authorities: :environment do
      fetch_and_process_api(:local_authorities)
    end
  end
end

def fetch_and_process_api(location_type)
  response = HTTParty.get(LOCATION_POLYGON_SETTINGS[location_type][:api])
  (response['features'] || []).each do |region_response|
    region_name = region_response.dig('attributes', LOCATION_POLYGON_SETTINGS[location_type][:name_key])
    geometry_rings = region_response.dig('geometry', 'rings')

    # The first ring tends to contain far more points than subsequent rings.
    # Boundary should be visualised to check how it should be used.
    # If algolia searches by polygon are slow, these boundaries could be downsampled significantly.
    points = []
    geometry_rings[0].each do |point|
      points.push(*point.reverse) # API returns coords in an unconventional lng,lat order
    end

    LocationPolygon.create(
      name: region_name,
      location_type: location_type.to_s,
      boundary: points
    )
  end
end
