FactoryBot.define do
  factory :location_polygon do
    transient do
      area { "POLYGON((0 0, 1 1, 0 1, 0 0))" }
      centroid { "POINT(0.33331264776372055 0.6666929898148579)" }
    end

    name { "London" }
    location_type { "cities" }

    after(:build) do |polygon, evaluator|
      if evaluator.area.present? && polygon.uk_area.nil?
        polygon.uk_area = if evaluator.area.is_a?(String)
                            GeoFactories.convert_wgs84_to_sr27700 GeoFactories::FACTORY_4326.parse_wkt(evaluator.area)
                          else
                            GeoFactories.convert_wgs84_to_sr27700 evaluator.area
                          end
      end
      if evaluator.centroid.present? && polygon.uk_centroid.nil?
        polygon.uk_centroid = if evaluator.centroid.is_a?(String)
                                GeoFactories.convert_wgs84_to_sr27700 GeoFactories::FACTORY_4326.parse_wkt(evaluator.centroid)
                              else
                                GeoFactories.convert_wgs84_to_sr27700 evaluator.centroid

                              end
      end
    end
  end
end
