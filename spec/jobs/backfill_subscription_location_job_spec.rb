require "rails_helper"

# rubocop:disable RSpec/MessageChain
# rubocop:disable RSpec/AnyInstance
RSpec.describe BackfillSubscriptionLocationJob do
  # Factories for generating geographic and cartesian areas/points
  let(:geographic_factory) { RGeo::Geographic.spherical_factory(srid: 4326) }
  let(:cartesian_factory) { RGeo::Cartesian.factory(srid: 4326) }

  # Polygon stubs
  let(:geographic_area) { geographic_factory.parse_wkt(polygon_wkt) }
  let(:polygon_wkt) { "POLYGON ((0.0 0.0, 0.0 1.0, 1.0 1.0, 1.0 0.0, 0.0 0.0))" }
  let(:cartesian_area) { cartesian_factory.parse_wkt(polygon_wkt) }
  let(:polygon) { instance_double(LocationPolygon, id: 1, name: "london", area: geographic_area) }

  # Geopoint stubs
  let(:coordinates) { [51.5074, -0.1278] }
  let(:point_wkt) { "POINT (-0.1278 51.5074)" }
  let(:geocoding_result) { instance_double(Geocoding, coordinates: coordinates) }

  before do
    # Stub Polygon lookups
    allow(LocationPolygon).to receive(:with_name).and_return(nil)
    allow(LocationPolygon).to receive(:with_name).with("london").and_return(polygon)
    allow(LocationPolygon).to receive_message_chain(:where, :pick).and_return(cartesian_area)

    # Stub Geocoding lookups
    allow(Geocoding).to receive(:new).and_return(instance_double(Geocoding, coordinates: Geocoding::COORDINATES_NO_MATCH))
    allow(Geocoding).to receive(:new).with("e12jp").and_return(geocoding_result)
    allow(RGeo::Cartesian.factory(srid: 4326))
      .to receive(:point).with(coordinates.second, coordinates.first).and_return(point_wkt)

    allow(Rails.logger).to receive(:info)
  end

  context "with subscriptions with a location matching a valid polygon" do
    let!(:subs_matching_polygon) do
      [
        Subscription.create!(search_criteria: { "location" => "london", "radius" => 10 }),
        Subscription.create!(search_criteria: { "location" => " LonDON ", "radius" => 10 }),
        Subscription.create!(search_criteria: { "location" => "london", "radius" => 200 }),
      ]
    end

    it "populates the location area and radius in metres for all of them" do
      described_class.perform_now
      subs_matching_polygon.each do |sub|
        sub.reload
        expect(sub.area.as_text).to eq(polygon_wkt)
        expect(sub.geopoint).to be_nil
        expect(sub.radius_in_metres).to eq(Subscription.convert_miles_to_metres(sub.search_criteria["radius"]))
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
        "BackfillSubscriptionLocationJob completed. Total unique locations: 2. Polygons: 2, Coordinates: 0, Invalid: 0.",
      )
      described_class.perform_now
    end
  end

  context "with subscriptions with a location not matching any polygon but with coordinates" do
    let!(:subs_matching_coordinates) do
      [
        Subscription.create!(search_criteria: { "location" => "E12JP", "radius" => 10 }),
        Subscription.create!(search_criteria: { "location" => " e12jp ", "radius" => 10 }),
        Subscription.create!(search_criteria: { "location" => "E12JP", "radius" => 15 }),
      ]
    end

    it "populates the geopoint and radius in metres for all of them" do
      described_class.perform_now
      subs_matching_coordinates.each do |sub|
        sub.reload
        expect(sub.area).to be_nil
        expect(sub.geopoint.as_text).to eq point_wkt
        expect(sub.radius_in_metres).to eq(Subscription.convert_miles_to_metres(sub.search_criteria["radius"]))
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
        "BackfillSubscriptionLocationJob completed. Total unique locations: 2. Polygons: 0, Coordinates: 2, Invalid: 0.",
      )
      described_class.perform_now
    end
  end

  context "with subscriptions with an invalid location" do
    let!(:subs_invalid) do
      [
        Subscription.create!(search_criteria: { "location" => "Paris, France", "radius" => 10 }),
        Subscription.create!(search_criteria: { "location" => "01234", "radius" => 10 }),
        Subscription.create!(search_criteria: { "location" => "+32", "radius" => 15 }),
      ]
    end

    before do
      allow(LocationPolygon).to receive(:with_name).and_return(nil)
      allow(Geocoding).to receive(:new).and_return(instance_double(Geocoding, coordinates: Geocoding::COORDINATES_NO_MATCH))
    end

    it "does not populate area, geopoint or radius_in_metres for any of them" do
      described_class.perform_now
      subs_invalid.each do |sub|
        sub.reload
        expect(sub.area).to be_nil
        expect(sub.geopoint).to be_nil
        expect(sub.radius_in_metres).to be_nil
      end
    end

    it "does not attempt any updates" do
      expect_any_instance_of(Subscription.const_get(:ActiveRecord_Relation)).not_to receive(:update_all)
      described_class.perform_now
    end

    it "logs the job stats" do
      expect(Rails.logger).to receive(:info).with(
        "BackfillSubscriptionLocationJob completed. Total unique locations: 3. Polygons: 0, Coordinates: 0, Invalid: 3.",
      )
      described_class.perform_now
    end
  end

  context "with a subscription matching a polygon with invalid geometry" do
    let!(:sub_invalid_polygon) do
      Subscription.create!(search_criteria: { "location" => "invalid_polygon", "radius" => 10 })
    end

    before do
      allow(LocationPolygon).to receive(:with_name).with("invalid_polygon").and_return(polygon)
      allow(geographic_area).to receive(:invalid_reason).and_raise(RGeo::Error::InvalidGeometry)
      allow(Geocoding).to receive(:new).with("invalid_polygon").and_return(geocoding_result)
    end

    it "does not populate area, and retrieves the geopoint instead" do
      described_class.perform_now

      expect(geographic_area).to have_received(:invalid_reason)

      sub_invalid_polygon.reload
      expect(sub_invalid_polygon.area).to be_nil
      expect(sub_invalid_polygon.geopoint.as_text).to eq point_wkt
      expect(sub_invalid_polygon.radius_in_metres).to eq(Subscription.convert_miles_to_metres(sub_invalid_polygon.search_criteria["radius"]))
    end
  end

  context "with subscriptions that have no location in their search criteria" do
    let!(:subs_no_location) do
      [
        Subscription.create!(search_criteria: { "radius" => 10 }),
        Subscription.create!(search_criteria: { "category" => "engineering" }),
      ]
    end

    it "does not populate area, geopoint or radius_in_metres for any of them" do
      described_class.perform_now
      subs_no_location.each do |sub|
        sub.reload
        expect(sub.area).to be_nil
        expect(sub.geopoint).to be_nil
        expect(sub.radius_in_metres).to be_nil
      end
    end

    it "does not attempt any updates" do
      expect_any_instance_of(Subscription.const_get(:ActiveRecord_Relation)).not_to receive(:update_all)
      described_class.perform_now
    end

    it "logs the job stats" do
      expect(Rails.logger).to receive(:info).with(
        "BackfillSubscriptionLocationJob completed. Total unique locations: 0. Polygons: 0, Coordinates: 0, Invalid: 0.",
      )
      described_class.perform_now
    end
  end

  context "with subscriptions matching a mix of polygon, coordinates invalid locations plus no location in the criteria" do
    let!(:sub_with_polygon) { Subscription.create!(search_criteria: { "location" => "london", "radius" => 10 }) }
    let!(:sub_with_coordinates) { Subscription.create!(search_criteria: { "location" => "E12JP", "radius" => 10 }) }
    let!(:sub_invalid) { Subscription.create!(search_criteria: { "location" => "Paris, France", "radius" => 10 }) }
    let!(:sub_no_location) { Subscription.create!(search_criteria: { "job_roles" => "[teacher]" }) }

    it "populates the area for the polygon match" do
      described_class.perform_now

      sub_with_polygon.reload
      expect(sub_with_polygon.area.as_text).to eq(polygon_wkt)
      expect(sub_with_polygon.geopoint).to be_nil
      expect(sub_with_polygon.radius_in_metres).to eq(Subscription.convert_miles_to_metres(sub_with_polygon.search_criteria["radius"]))
    end

    it "populates the geopoint for the coordinates match" do
      described_class.perform_now

      sub_with_coordinates.reload
      expect(sub_with_coordinates.area).to be_nil
      expect(sub_with_coordinates.geopoint.as_text).to eq point_wkt
      expect(sub_with_coordinates.radius_in_metres).to eq(Subscription.convert_miles_to_metres(sub_with_coordinates.search_criteria["radius"]))
    end

    it "does not populate any location info for the invalid location or no location" do
      described_class.perform_now
      sub_invalid.reload
      expect(sub_invalid.area).to be_nil
      expect(sub_invalid.geopoint).to be_nil
      expect(sub_invalid.radius_in_metres).to be_nil

      sub_no_location.reload
      expect(sub_no_location.area).to be_nil
      expect(sub_no_location.geopoint).to be_nil
      expect(sub_no_location.radius_in_metres).to be_nil
    end

    it "logs the job stats" do
      expect(Rails.logger).to receive(:info).with(
        "BackfillSubscriptionLocationJob completed. Total unique locations: 3. Polygons: 1, Coordinates: 1, Invalid: 1.",
      )
      described_class.perform_now
    end
  end
end
# rubocop:enable RSpec/AnyInstance
# rubocop:enable RSpec/MessageChain
