require "rails_helper"

RSpec.describe Search::RadiusBuilder do
  subject { described_class.new(location, radius) }

  let(:location) { "placename" }

  before do
    stub_const("Search::RadiusBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES", 32)
    stub_const("Search::RadiusBuilder::DEFAULT_BUFFER_FOR_POLYGON_SEARCHES", 64)
  end

  describe "#initialize" do
    context "when a non-polygonable location is specified" do
      context "when no radius is specified" do
        let(:radius) { nil }

        it "sets radius attribute to the default radius for point location searches" do
          expect(subject.radius).to eq(32)
        end
      end

      context "when a radius is specified" do
        let(:radius) { 1024 }

        it "sets radius attribute to the specified radius" do
          expect(subject.radius).to eq(1024)
        end

        context "when the radius is the same as DEFAULT_BUFFER_FOR_POLYGON_SEARCHES" do
          let(:radius) { 64 }

          it "sets radius attribute to the default radius for point location searches" do
            expect(subject.radius).to eq(32)
          end
        end
      end
    end

    context "when a polygonable location is specified" do
      before { allow(LocationPolygon).to receive(:include?).with(location).and_return(true) }

      context "when no radius is specified" do
        let(:radius) { nil }

        it "sets radius attribute to the default radius for polygon location searches" do
          expect(subject.radius).to eq(64)
        end
      end

      context "when a radius is specified" do
        let(:radius) { 1024 }

        it "sets radius attribute to the specified radius" do
          expect(subject.radius).to eq(1024)
        end

        context "when the radius is the same as DEFAULT_BUFFER_FOR_POLYGON_SEARCHES" do
          let(:radius) { 64 }

          it "preserves the radius attribute" do
            expect(subject.radius).to eq(64)
          end
        end
      end
    end
  end
end
