require "rails_helper"

RSpec.shared_examples "a successful import" do
  it "imports the location" do
    expect(imported_polygon.name).to eq(location_name)
  end

  it "assigns the location type correctly" do
    expect(imported_polygon.location_type).to eq(human_friendly_location_type || api_location_type&.to_s)
  end

  it "imports the boundary" do
    expect(imported_polygon.boundary).to eq(boundary_points)
  end
end

RSpec.shared_examples "an import that excludes out-of-scope locations" do
  it "does not import out-of-scope locations" do
    expect(LocationPolygon.send(api_location_type).count).to eq(1)
  end
end

RSpec.describe ImportPolygons do
  subject { described_class.new(api_location_type: api_location_type) }
  let(:boundary_endpoint) { LOCATION_POLYGON_SETTINGS[api_location_type][:boundary_api] }
  let(:boundary_response) { file_fixture(file_name).read }
  let(:file_name) { "ons_#{api_location_type}.json" }
  let(:imported_polygon) { LocationPolygon.find_by(name: location_name) }

  before do
    allow(HTTParty).to receive(:get).with(boundary_endpoint).and_return(boundary_response)
  end

  describe "#call" do
    context "when stubbing #get_buffers" do
      let(:human_friendly_location_type) { nil }

      before do
        allow(subject).to receive(:get_buffers).with(boundary_points).and_return({ "5" => %w[lat lon], "10" => %w[lat lon] })
        subject.call
      end

      context "when using the regions API endpoint" do
        let(:api_location_type) { :regions }
        let(:location_name) { "north east" }
        let(:boundary_points) { [55.8110853660943, -2.0343575091738, 55.7647624900862, -1.9841097397706] }

        it_behaves_like "a successful import"
        it_behaves_like "an import that excludes out-of-scope locations"

        context "when the location categorisation for vacancy faceting differs from ONS' categorisation" do
          let(:location_name) { "london" }
          let(:human_friendly_location_type) { "cities" }

          it_behaves_like "a successful import"
        end
      end

      context "when using the counties and unitary authorities API endpoint" do
        let(:api_location_type) { :counties }
        let(:location_name) { "cumbria" }
        let(:boundary_points) { [54.6991864051642, -1.1776332863422, 54.6918238899294, -1.1739811767539] }

        it_behaves_like "a successful import"
        it_behaves_like "an import that excludes out-of-scope locations"

        context "when the location categorisation for vacancy faceting differs from ONS' categorisation" do
          let(:location_name) { "leeds" }
          let(:human_friendly_location_type) { "cities" }

          it_behaves_like "a successful import"
        end
      end

      context "when using the cities API endpoint" do
        let(:api_location_type) { :cities }
        let(:location_name) { "bath" }
        let(:boundary_points) { [51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145] }

        it_behaves_like "a successful import"
        it_behaves_like "an import that excludes out-of-scope locations"
      end
    end

    describe "#get_buffers" do
      let(:api_location_type) { :cities }
      let(:location_name) { "bath" }
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

      context "when the points in the response are the same as the last time the task was run" do
        let(:boundary_points) { [51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145] }
        let(:original_buffers) { { "5" => "This is a hash that won't be updated" } }

        before do
          LocationPolygon.create(name: location_name, location_type: "cities", boundary: boundary_points, buffers: original_buffers)
          subject.call
        end

        it "skips the buffers API call and returns the current buffers" do
          expect(imported_polygon.buffers).to eq(original_buffers)
        end
      end

      context "when the points are different from the last time the task was run" do
        context "when the length of the params causes the API endpoint length to exceed the maximum" do
          before do
            stub_const("ImportPolygons::URL_MAXIMUM_LENGTH", 398)
            distances = [5, 10, 15, 20, 25]
            distances.each do |distance|
              allow(HTTParty).to receive(:get).with(
                "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?bufferSR=3857&"\
                "distances=#{convert_miles_to_metres(distance)}&f=json&geodesic=false&geometries=%7B%22geometryType"\
                "%22%3D%3E%22esriGeometryPolygon%22%2C+%22geometries%22%3D%3E%5B%7B%22rings%22%3D%3E%5B%5B%5B"\
                "51.406361958644%2C+-2.3780576677997%5D%5D%5D%7D%5D%7D&inSR=4326&outSR=4326&unionResults=true&unit=",
              ).and_return(buffer_response)
            end
            subject.call
          end

          it "is still able to import the buffers, by reducing the number of coordinates in the params of the API endpoint" do
            expect(imported_polygon.buffers).to eq(imported_buffers)
          end
        end

        context "when the length of the params does not cause the API endpoint length to exceed the maximum" do
          let(:api_location_type) { :regions }
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
