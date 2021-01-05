require "rails_helper"

RSpec.describe ImportPolygons do
  subject { described_class.new(location_type: location_type) }
  let(:boundary_endpoint) { LOCATION_POLYGON_SETTINGS[location_type][:boundary_api] }
  let(:boundary_response) { file_fixture(file_name).read }
  let(:file_name) { "ons_#{location_type}.json" }

  before do
    allow(HTTParty).to receive(:get).with(boundary_endpoint).and_return(boundary_response)
  end

  describe "#call" do
    context "when stubbing #get_buffers" do
      before do
        allow(subject).to receive(:get_buffers).with(boundary_points).and_return({ "5" => %w[lat lon], "10" => %w[lat lon] })
        subject.call
      end

      context "when location type is regions" do
        let(:location_type) { :regions }
        let(:boundary_points) { [55.8110853660943, -2.0343575091738, 55.7647624900862, -1.9841097397706] }

        it "imports North East region" do
          expect(LocationPolygon.regions.first.name).to eq("north east")
        end

        it "imports North East boundary" do
          expect(LocationPolygon.regions.first.boundary).to eq(boundary_points)
        end

        it "does not import non-existent region" do
          expect(LocationPolygon.regions.count).to eq(1)
        end
      end

      context "when location type is counties" do
        let(:location_type) { :counties }
        let(:boundary_points) { [52, 0, 52, 0, 52, 0, 52, 0, 52, 0, 52, 0] }

        it "imports Cumbria county" do
          expect(LocationPolygon.counties.first.name).to eq("cumbria")
        end

        it "imports Cumbria boundary" do
          expect(LocationPolygon.counties.first.boundary).to eq(boundary_points)
        end

        it "does not import non-existent county" do
          expect(LocationPolygon.counties.count).to eq(1)
        end

        context "when the location is a composite location" do
          let(:location_type) { :counties }
          let(:file_name) { "ons_counties_with_composite_location.json" }
          let(:boundary_points) { [51.0, 0.1, 51.0, -0.1] }

          it "imports Central Bedfordshire" do
            expect(LocationPolygon.counties.first.name).to eq("central bedfordshire")
          end

          it "imports Central Bedfordshire boundary" do
            expect(LocationPolygon.counties.first.boundary).to eq(boundary_points)
          end

          it "does not import non-existent unitary authority" do
            expect(LocationPolygon.counties.count).to eq(1)
          end
        end
      end

      context "when location type is cities" do
        let(:location_type) { :cities }
        let(:boundary_points) { [51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145] }

        it "imports Bath city" do
          expect(LocationPolygon.cities.first.name).to eq("bath")
        end

        it "imports Bath boundary" do
          expect(LocationPolygon.cities.first.boundary).to eq(boundary_points)
        end

        it "does not import non-existent city" do
          expect(LocationPolygon.cities.count).to eq(1)
        end
      end
    end

    describe "#get_buffers" do
      let(:location_type) { :counties }
      let(:location_name) { "cumbria" }
      let(:buffer_response) { JSON.parse(file_fixture("buffer_response.json").read) }
      let(:buffer_coordinates) { [65.06414131400004, -12.5761721229999353, 65.06185937400005, -12.5761901179999427] }
      let(:imported_buffers) do
        {
          "5" => buffer_coordinates,
          "10" => buffer_coordinates,
          "15" => buffer_coordinates,
          "20" => buffer_coordinates,
          "25" => buffer_coordinates,
        }
      end
      let(:imported_polygon) { LocationPolygon.find_by(name: location_name, location_type: location_type) }

      context "when the points are the same as the last time the task was run" do
        let(:boundary_points) { [52, 0, 52, 0, 52, 0, 52, 0, 52, 0, 52, 0] }
        let(:original_buffers) { { "5" => "This is a hash that won't be updated" } }

        before do
          LocationPolygon.create(name: location_name, location_type: location_type.to_s, boundary: boundary_points, buffers: original_buffers)
          subject.call
        end

        it "skips the buffers API call and returns the current buffers" do
          expect(imported_polygon.buffers).to eq(original_buffers)
        end
      end

      context "when the points have changed since the last time the task was run" do
        context "when the length of the params does not cause the API endpoint length to exceed the maximum" do
          before do
            stub_const("ImportPolygons::URL_MAXIMUM_LENGTH", 400)
            distances = [5, 10, 15, 20, 25]
            distances.each do |distance|
              allow(HTTParty).to receive(:get).with(
                "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?"\
                "bufferSR=3857&distances=#{convert_miles_to_metres(distance)}&f"\
                "=json&geodesic=false&geometries=%7B%22geometryType%22%3D%3E%22esriGeometryPolygon%22%2C+%22"\
                "geometries%22%3D%3E%5B%7B%22rings%22%3D%3E%5B%5B%5B52%2C+0%5D%2C+%5B52%2C+0%5D%5D%5D%7D%5D%7D"\
                "&inSR=4326&outSR=4326&unionResults=true&unit=",
              ).and_return(buffer_response)
            end
            subject.call
          end

          it "is still able to import the buffers, by reducing the number of coordinates in the params of the API endpoint" do
            expect(imported_polygon.buffers).to eq(imported_buffers)
          end
        end

        context "when the length of the params causes the API endpoint length to exceed the maximum" do
          let(:location_type) { :regions }
          let(:location_name) { "north east" }

          before do
            distances = [5, 10, 15, 20, 25]
            distances.each do |distance|
              allow(HTTParty).to receive(:get).with(
                "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?"\
                "bufferSR=3857&distances=#{convert_miles_to_metres(distance)}&f=json&geodesic=f"\
                "alse&geometries=%7B%22geometryType%22%3D%3E%22esriGeometryPolygon%22%2C+%22geometries%22%3D%3E"\
                "%5B%7B%22rings%22%3D%3E%5B%5B%5B55.8110853660943%2C+-2.0343575091738%5D%2C+%5B55.7647624900862%"\
                "2C+-1.9841097397706%5D%5D%5D%7D%5D%7D&inSR=4326&outSR=4326&unionResults=true&unit=",
              ).and_return(buffer_response)
            end
            subject.call
          end

          it "imports buffers" do
            expect(imported_polygon.buffers).to eq(imported_buffers)
          end
        end
      end
    end
  end
end
