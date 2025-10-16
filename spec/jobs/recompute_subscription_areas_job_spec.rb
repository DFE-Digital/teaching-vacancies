require "rails_helper"

# rubocop:disable RSpec/AnyInstance
RSpec.describe RecomputeSubscriptionAreasJob do
  # Factories for generating geographic and cartesian areas/points
  let(:geographic_factory) { RGeo::Geographic.spherical_factory(srid: 4326) }
  let(:cartesian_factory) { RGeo::Cartesian.factory(srid: 4326) }

  # Polygon stubs
  let(:previous_polygon_wkt) { "POLYGON ((0.0 0.0, 0.0 2.0, 2.0 2.0, 2.0 0.0, 0.0 0.0))" }
  let(:previous_area) { geographic_factory.parse_wkt(previous_polygon_wkt) }
  let(:geographic_area) { geographic_factory.parse_wkt(polygon_wkt) }
  let(:polygon_wkt) { "POLYGON ((0.0 0.0, 0.0 1.0, 1.0 1.0, 1.0 0.0, 0.0 0.0))" }
  let(:cartesian_area) { cartesian_factory.parse_wkt(polygon_wkt) }
  let(:polygon) do
    instance_double(LocationPolygon, id: 1, name: "london", area: geographic_area, buffered_geometry_area: cartesian_area)
  end

  before do
    allow(LocationPolygon).to receive(:find_valid_for_location).and_return(nil)
    allow(LocationPolygon).to receive(:find_valid_for_location).with("london").and_return(polygon)
    allow(Rails.logger).to receive(:info)
  end

  context "with subscriptions with an already existing area" do
    let!(:subs_matching_polygon) do
      [
        Subscription.create!(search_criteria: { "location" => "london", "radius" => 10 }, area: previous_area),
        Subscription.create!(search_criteria: { "location" => " LonDON ", "radius" => 10 }, area: previous_area),
        Subscription.create!(search_criteria: { "location" => "london", "radius" => 200 }, area: previous_area),
      ]
    end

    it "recomputes the area for all of them" do
      described_class.perform_now
      subs_matching_polygon.each do |sub|
        sub.reload
        expect(sub.area.as_text).to eq(polygon_wkt)
      end
    end

    it "does a single update for all the subscriptions matching the same location/radius pair" do
      updated_instances = []

      allow_any_instance_of(Subscription.const_get(:ActiveRecord_Relation)).to receive(:update_all) do |instance, *_args|
        updated_instances << instance
      end

      described_class.perform_now

      expect(updated_instances.size).to eq(2)
      expect(updated_instances.uniq.size).to eq(2)
    end

    it "logs the job stats" do
      expect(Rails.logger).to receive(:info).with(
        "RecomputeSubscriptionAreasJob completed. Total unique locations: 2. Polygons: 2, Invalid: 0.",
      )
      described_class.perform_now
    end

    context "when the location now doesn't match a valid polygon" do
      before do
        allow(LocationPolygon).to receive(:find_valid_for_location).with("london").and_return(nil)
      end

      it "doesn't update the subscriptions" do
        described_class.perform_now
        subs_matching_polygon.each do |sub|
          sub.reload
          expect(sub.area.as_text).to eq(previous_polygon_wkt)
        end
      end

      it "logs the job stats" do
        expect(Rails.logger).to receive(:info).with(
          "RecomputeSubscriptionAreasJob completed. Total unique locations: 2. Polygons: 0, Invalid: 2.",
        )
        described_class.perform_now
      end
    end
  end

  context "with subscriptions without an area" do
    let!(:sub_without_area) { Subscription.create!(search_criteria: { "location" => "london", "radius" => 10 }, area: nil) }

    it "doesn't update the subscription" do
      described_class.perform_now
      sub_without_area.reload
      expect(sub_without_area.area).to be_nil
    end

    it "logs the job stats" do
      expect(Rails.logger).to receive(:info).with(
        "RecomputeSubscriptionAreasJob completed. Total unique locations: 0. Polygons: 0, Invalid: 0.",
      )
      described_class.perform_now
    end
  end

  context "with subscriptions with a geopoint but no area" do
    let!(:sub_with_geopoint) do
      Subscription.create!(search_criteria: { "location" => "london", "radius" => 10 }, area: nil, geopoint: cartesian_factory.point(1, 1))
    end

    it "doesn't update the subscription" do
      described_class.perform_now
      sub_with_geopoint.reload
      expect(sub_with_geopoint.area).to be_nil
    end

    it "logs the job stats" do
      expect(Rails.logger).to receive(:info).with(
        "RecomputeSubscriptionAreasJob completed. Total unique locations: 0. Polygons: 0, Invalid: 0.",
      )
      described_class.perform_now
    end
  end
end
# rubocop:enable RSpec/AnyInstance
