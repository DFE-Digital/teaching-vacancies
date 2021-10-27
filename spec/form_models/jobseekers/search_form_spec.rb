require "rails_helper"

RSpec.describe Jobseekers::SearchForm, type: :model do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:location) { "North Nowhere" }

    before do
      stub_const("Search::LocationBuilder::DEFAULT_RADIUS_FOR_POINT_SEARCHES", 32)
      stub_const("Search::LocationBuilder::DEFAULT_BUFFER_FOR_POLYGON_SEARCHES", 56)
    end

    context "when a radius is provided" do
      let(:radius) { "1" }

      context "when a location is provided" do
        let(:params) { { radius: radius, location: location } }

        context "when the location is a polygon" do
          before do
            allow(LocationPolygon).to receive(:include?).with(location).and_return(true)
            create(:location_polygon, name: location.downcase)
          end

          it "assigns the radius attribute to the radius param" do
            expect(subject.radius).to eq("1")
          end

          context "when the radius equals DEFAULT_BUFFER_FOR_POLYGON_SEARCHES" do
            let(:radius) { "56" }

            it "preserves the radius attribute" do
              expect(subject.radius).to eq("56")
            end
          end
        end

        context "when the location is not a polygon" do
          it "assigns the radius attribute to the radius param" do
            expect(subject.radius).to eq("1")
          end

          context "when the radius equals DEFAULT_BUFFER_FOR_POLYGON_SEARCHES" do
            let(:radius) { "56" }

            it "assigns the radius attribute to the default for point searches" do
              expect(subject.radius).to eq("32")
            end
          end
        end
      end

      context "when a location is not provided" do
        let(:params) { { radius: radius } }

        it "assigns the radius attribute to the default radius for polygon searches" do
          expect(subject.radius).to eq("56")
        end
      end
    end

    context "when a radius is not provided" do
      context "when a location is provided" do
        let(:params) { { location: location } }

        context "when the location is a polygon" do
          before do
            allow(LocationPolygon).to receive(:include?).with(location).and_return(true)
            create(:location_polygon, name: location.downcase)
          end

          it "assigns the radius attribute to the default radius for polygons" do
            expect(subject.radius).to eq("56")
          end
        end

        context "when the location is not a polygon" do
          it "assigns the radius attribute to the default radius for point searches" do
            expect(subject.radius).to eq("32")
          end
        end
      end

      context "when a location is not provided" do
        let(:params) { {} }

        it "assigns the radius attribute to the default radius for polygon searches" do
          expect(subject.radius).to eq("56")
        end
      end
    end
  end

  describe "#strip_trailing_whitespaces_from_params" do
    context "when user input contains trailing whitespace" do
      let(:keyword) { " teacher " }
      let(:location) { "the big smoke " }
      let(:params) { { keyword: keyword, location: location } }

      it "strips the whitespace before saving the attribute" do
        expect(subject.keyword).to eq "teacher"
        expect(subject.location).to eq "the big smoke"
      end
    end
  end
end
