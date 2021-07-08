require "rails_helper"

RSpec.shared_examples "a successful import" do
  it "imports the location" do
    expect(imported_polygon.name).to eq(location_name)
  end

  it "assigns the location type correctly" do
    expect(imported_polygon.location_type).to eq(human_friendly_location_type || api_location_type&.to_s)
  end

  it "imports the boundary polygons" do
    expect(imported_polygon.polygons).to eq(polygons)
  end
end

RSpec.shared_examples "an import that excludes out-of-scope locations" do
  it "does not import out-of-scope locations" do
    expect(LocationPolygon.where(location_type: human_friendly_location_type).count).to eq(1)
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
        allow(subject).to receive(:get_buffers).with(polygons["polygons"]).and_return({ "5" => %w[lat lon], "10" => %w[lat lon] })
        subject.call
      end

      context "when using the regions API endpoint" do
        let(:api_location_type) { :regions }
        let(:human_friendly_location_type) { "regions" }
        let(:location_name) { "north east" }
        let(:polygons) do
          { "polygons" => [[55.8110853660943, -2.0343575091738, 55.7647624900862, -1.9841097397706], [52, 0, 53, 1]] }
        end

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
        let(:human_friendly_location_type) { "counties" }
        let(:location_name) { "cumbria" }
        let(:polygons) do
          { "polygons" => [[53, 1, 54, 2], [54.6991864051642, -1.1776332863422, 54.6918238899294, -1.1739811767539]] }
        end

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
        let(:human_friendly_location_type) { "cities" }
        let(:location_name) { "bath" }
        let(:polygons) { { "polygons" => [[51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145]] } }

        it_behaves_like "a successful import"
        it_behaves_like "an import that excludes out-of-scope locations"
      end
    end

    describe "#get_buffers" do
      let(:api_location_type) { :cities }
      let(:location_name) { "bath" }
      let(:polygons) do
        { "polygons" => [[51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145]] }
      end
      let(:buffer_response) { JSON.parse(file_fixture("buffer_response.json").read) }
      let(:buffer_polygon) { buffer_response.dig("geometries", 0, "rings").flatten }
      let(:original_buffers) do
        {
          "1" => "An original buffer polygon",
          "5" => "An original buffer polygon",
          "10" => "An original buffer polygon",
          "15" => "An original buffer polygon",
          "20" => "An original buffer polygon",
          "25" => "An original buffer polygon",
          "30" => "An original buffer polygon",
          "35" => "An original buffer polygon",
          "40" => "An original buffer polygon",
          "45" => "An original buffer polygon",
          "50" => "An original buffer polygon",
          "55" => "An original buffer polygon",
          "60" => "An original buffer polygon",
          "70" => "An original buffer polygon",
          "80" => "An original buffer polygon",
          "90" => "An original buffer polygon",
          "100" => "An original buffer polygon",
          "200" => "An original buffer polygon",
        }
      end
      let(:new_buffers) do
        {
          "1" => [buffer_polygon],
          "5" => [buffer_polygon],
          "10" => [buffer_polygon],
          "15" => [buffer_polygon],
          "20" => [buffer_polygon],
          "25" => [buffer_polygon],
          "30" => [buffer_polygon],
          "35" => [buffer_polygon],
          "40" => [buffer_polygon],
          "45" => [buffer_polygon],
          "50" => [buffer_polygon],
          "55" => [buffer_polygon],
          "60" => [buffer_polygon],
          "70" => [buffer_polygon],
          "80" => [buffer_polygon],
          "90" => [buffer_polygon],
          "100" => [buffer_polygon],
          "200" => [buffer_polygon],
        }
      end

      before do
        create(:location_polygon,
               name: location_name,
               location_type: api_location_type,
               polygons: polygons,
               buffers: original_buffers)
      end

      context "when the buffer radius options are different from the last time the task was run" do
        let(:new_buffers) do
          {
            "1" => [[65.06414131400004, -12.576172122999935, 65.06185937400005, -12.576190117999943]],
            "2" => [[65.06414131400004, -12.576172122999935, 65.06185937400005, -12.576190117999943]],
            "99" => [[65.06414131400004, -12.576172122999935, 65.06185937400005, -12.576190117999943]],
            "100" => [[65.06414131400004, -12.576172122999935, 65.06185937400005, -12.576190117999943]],
          }
        end

        before do
          stub_const("ImportPolygons::BUFFER_RADII", [1, 2, 99, 100])
          ImportPolygons::BUFFER_RADII.each do |distance|
            allow(HTTParty).to receive(:get).with(
              "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?bufferSR=3857&"\
              "distances=#{convert_miles_to_metres(distance)}&f=json&geodesic=false&geometries=%7B%22geometryType"\
              "%22%3D%3E%22esriGeometryPolygon%22%2C+%22geometries%22%3D%3E%5B%7B%22rings%22%3D%3E%5B%5B%5B"\
              "51.406361958644%2C+-2.3780576677997%5D%2C+%5B51.4063596372237%2C+-2.3787764623145%5D%5D%5D%7D%"\
              "5D%7D&inSR=4326&outSR=4326&unionResults=true&unit=",
            ).and_return(buffer_response)
          end
          subject.call
        end

        it "imports buffers" do
          expect(imported_polygon.buffers).to eq(new_buffers)
        end
      end

      context "when the buffer radius options are the same as the last time the task was run" do
        it "skips the buffers API call and returns the current buffers" do
          expect(subject).to_not receive(:get_buffers)
          expect(imported_polygon.buffers).to eq(original_buffers)
          subject.call
        end
      end

      context "when the points in the response are the same as the last time the task was run" do
        it "skips the buffers API call and returns the current buffers" do
          expect(subject).to_not receive(:get_buffers)
          expect(imported_polygon.buffers).to eq(original_buffers)
          subject.call
        end
      end

      context "when the points are different from the last time the task was run" do
        let(:polygons) do
          { "polygons" => [["original polygon", "original polygon", "original polygon", "original polygon"]] }
        end

        context "when the length of the params causes the API endpoint length to exceed the maximum" do
          before do
            stub_const("ImportPolygons::URL_MAXIMUM_LENGTH", 398)
            ImportPolygons::BUFFER_RADII.each do |distance|
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
            expect(imported_polygon.buffers).to eq(new_buffers)
          end
        end

        context "when the length of the params does not cause the API endpoint length to exceed the maximum" do
          let(:api_location_type) { :regions }
          let(:location_name) { "north east" }
          let(:new_buffers) do
            {
              "1" => [buffer_polygon, buffer_polygon],
              "5" => [buffer_polygon, buffer_polygon],
              "10" => [buffer_polygon, buffer_polygon],
              "15" => [buffer_polygon, buffer_polygon],
              "20" => [buffer_polygon, buffer_polygon],
              "25" => [buffer_polygon, buffer_polygon],
              "30" => [buffer_polygon, buffer_polygon],
              "35" => [buffer_polygon, buffer_polygon],
              "40" => [buffer_polygon, buffer_polygon],
              "45" => [buffer_polygon, buffer_polygon],
              "50" => [buffer_polygon, buffer_polygon],
              "55" => [buffer_polygon, buffer_polygon],
              "60" => [buffer_polygon, buffer_polygon],
              "70" => [buffer_polygon, buffer_polygon],
              "80" => [buffer_polygon, buffer_polygon],
              "90" => [buffer_polygon, buffer_polygon],
              "100" => [buffer_polygon, buffer_polygon],
              "200" => [buffer_polygon, buffer_polygon],
            }
          end

          before do
            ImportPolygons::BUFFER_RADII.each do |distance|
              # These two long strings are different; they depend on the boundaries of each of the regions.
              allow(HTTParty).to receive(:get).with(
                "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?bufferSR=3857&"\
                "distances=#{convert_miles_to_metres(distance)}&f=json&geodesic=false&geometries=%7B%22geometryType"\
                "%22%3D%3E%22esriGeometryPolygon%22%2C+%22geometries%22%3D%3E%5B%7B%22rings%22%3D%3E%5B%5B%5B"\
                "55.8110853660943%2C+-2.0343575091738%5D%2C+%5B55.7647624900862%2C+-1.9841097397706%5D%5D%5D%7D%5D%7D"\
                "&inSR=4326&outSR=4326&unionResults=true&unit=",
              ).and_return(buffer_response)
              allow(HTTParty).to receive(:get).with(
                "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?bufferSR=3857&"\
                "distances=#{convert_miles_to_metres(distance)}&f=json&geodesic=false&geometries=%7B%22geometryType"\
                "%22%3D%3E%22esriGeometryPolygon%22%2C+%22geometries%22%3D%3E%5B%7B%22rings%22%3D%3E%5B%5B%5B52%2C+"\
                "0%5D%2C+%5B53%2C+1%5D%5D%5D%7D%5D%7D&inSR=4326&outSR=4326&unionResults=true&unit=",
              ).and_return(buffer_response)
            end
            subject.call
          end

          it "imports buffers" do
            expect(imported_polygon.buffers).to eq(new_buffers)
          end
        end
      end
    end
  end
end
