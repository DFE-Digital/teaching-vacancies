FactoryBot.define do
  factory :location_polygon do
    name { "london" }
    location_type { "cities" }
    area { "POLYGON((0 0, 1 1, 0 1, 0 0))" }
    centroid { "POINT(0.33331264776372055 0.6666929898148579)" }

    after(:build) do |polygon|
      if polygon.area.present? && polygon.uk_area.nil?
        polygon.uk_area = if polygon.area.is_a?(String)
                            GeoFactories.convert_wgs84_to_sr27700 GeoFactories::FACTORY_4326.parse_wkt(polygon.area)
                          else
                            GeoFactories.convert_wgs84_to_sr27700 polygon.area
                          end
      end
      if polygon.centroid.present? && polygon.uk_centroid.nil?
        polygon.uk_centroid = if polygon.centroid.is_a?(String)
                                GeoFactories.convert_wgs84_to_sr27700 GeoFactories::FACTORY_4326.parse_wkt(polygon.centroid)
                              else
                                GeoFactories.convert_wgs84_to_sr27700 polygon.centroid
                              end
      end
    end
  end
end
