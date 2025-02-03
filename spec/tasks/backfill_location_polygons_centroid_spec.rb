require "rails_helper"

RSpec.describe "location_polygons:backfill_centroid" do
  let(:area) { "POLYGON((0 0, 1 1, 0 1, 0 0))" }
  let(:centroid) { "POINT(0.33331264776372055 0.6666929898148579)" }

  it "computes and sets the centroid on location polygons containing an area but no centroid" do
    location_polygon = create(:location_polygon, area: area, centroid: nil)

    expect { task.invoke }.to change { location_polygon.reload.centroid }.from(nil).to(
      RGeo::Geographic.spherical_factory(srid: 4326).parse_wkt(centroid),
    )
  end

  it "does not update the centroid if it is already set" do
    location_polygon = create(:location_polygon, area: area, centroid: centroid)

    expect { task.invoke }.not_to(change { location_polygon.reload.centroid })
  end

  it "does not update the centroid if the area is nil" do
    location_polygon = create(:location_polygon, area: nil, centroid: nil)

    expect { task.invoke }.not_to(change { location_polygon.reload.centroid })
  end
end
