FactoryBot.define do
  factory :location_polygon do
    name { "London" }
    location_type { "cities" }
    area { "POLYGON((0 0, 1 1, 0 1, 0 0))" }
    centroid { "POINT(0.33331264776372055 0.6666929898148579)" }
  end
end
