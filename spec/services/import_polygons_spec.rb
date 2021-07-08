require "rails_helper"

RSpec.shared_examples "a successful import" do
  it "imports the location" do
    expect(imported_polygon.name).to eq(location_name)
  end

  it "assigns the location type correctly" do
    expect(imported_polygon.location_type).to eq(human_friendly_location_type || api_location_type&.to_s)
  end

  it "imports the boundary polygons" do
    expect(imported_polygon.buffers).to eq(buffers_hash)
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
  let(:buffers_hash) do
    {
      "1" => [[155.8110853660943, -12.0343575091738, 155.7647624900862, -11.9841097397706], [52, 0, 53, 1]],
      "5" => [[155.8110853660943, -12.0343575091738, 155.7647624900862, -11.9841097397706], [52, 0, 53, 1]],
      "10" => [[155.8110853660943, -12.0343575091738, 155.7647624900862, -11.9841097397706], [52, 0, 53, 1]],
      "25" => [[155.8110853660943, -12.0343575091738, 155.7647624900862, -11.9841097397706], [52, 0, 53, 1]],
      "50" => [[155.8110853660943, -12.0343575091738, 155.7647624900862, -11.9841097397706], [52, 0, 53, 1]],
      "100" => [[155.8110853660943, -12.0343575091738, 155.7647624900862, -11.9841097397706], [52, 0, 53, 1]],
      "200" => [[155.8110853660943, -12.0343575091738, 155.7647624900862, -11.9841097397706], [52, 0, 53, 1]],
    }
  end

  before do
    allow(HTTParty).to receive(:get).with(boundary_endpoint).and_return(boundary_response)
  end

  describe "#call" do
    context "when stubbing #buffered_polygons" do
      let(:human_friendly_location_type) { nil }

      before do
        allow(subject).to receive(:buffered_polygons).with(polygons_from_arcgis["polygons"]).and_return(buffers_hash)
        subject.call
      end

      context "when using the regions API endpoint" do
        let(:api_location_type) { :regions }
        let(:human_friendly_location_type) { "regions" }
        let(:location_name) { "north east" }
        let(:polygons_from_arcgis) do
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
        let(:polygons_from_arcgis) do
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
        let(:polygons_from_arcgis) do
          { "polygons" => [[51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145]] }
        end

        it_behaves_like "a successful import"
        it_behaves_like "an import that excludes out-of-scope locations"
      end
    end

    describe "#buffered_polygons" do
      let(:api_location_type) { :cities }
      let(:buffer_response) { JSON.parse(file_fixture("buffer_response.json").read) }
      let(:buffer_response_boundary) { buffer_response.dig("geometries", 0, "rings").flatten }
      let(:unchanged_buffers_response) { { "geometries" => [{ "rings" => [[["This is a polygon"]]] }] } }
      let(:location_name) { "bath" }
      let(:original_polygons) do
        {
          "1" => [["This is a polygon"]],
          "5" => [["This is a polygon"]],
          "10" => [["This is a polygon"]],
          "15" => [["This is a polygon"]],
          "20" => [["This is a polygon"]],
          "25" => [["This is a polygon"]],
          "30" => [["This is a polygon"]],
          "35" => [["This is a polygon"]],
          "40" => [["This is a polygon"]],
          "45" => [["This is a polygon"]],
          "50" => [["This is a polygon"]],
          "55" => [["This is a polygon"]],
          "60" => [["This is a polygon"]],
          "70" => [["This is a polygon"]],
          "80" => [["This is a polygon"]],
          "90" => [["This is a polygon"]],
          "100" => [["This is a polygon"]],
          "200" => [["This is a polygon"]],
        }
      end

      before do
        create(:location_polygon,
               name: location_name,
               location_type: api_location_type,
               buffers: original_polygons)
      end

      context "when the first buffer polygon retrieved is the same as the last time the task was run" do
        before do
          allow(HTTParty).to receive(:get).with(
            "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?bufferSR=3857&"\
            "distances=#{convert_miles_to_metres(ImportPolygons::BUFFER_RADII.first)}&f=json&geodesic=false&geometries=%7B%22geometryType%22%3D%3E%22esriGeometryPolygon%"\
            "22%2C+%22geometries%22%3D%3E%5B%7B%22rings%22%3D%3E%5B%5B%5B51.406361958644%2C+-2.3780576677997%5D%"\
            "2C+%5B51.4063596372237%2C+-2.3787764623145%5D%5D%5D%7D%5D%7D&inSR=4326&outSR=4326&unionResults=true&"\
            "unit=",
          ).and_return(unchanged_buffers_response)
        end

        it "skips the API calls that return all of the buffered polygons and returns the current buffers" do
          expect(subject).to_not receive(:buffered_polygons)
          expect(imported_polygon.buffers).to eq(original_polygons)
          subject.call
        end
      end

      context "when the first buffer polygon retreived is different to the last time the task was run" do
        let(:first_buffer_check_api_response) { { "geometries" => [{ "rings" => [[["This is a polygon"]]] }] } }
        let(:new_polygons) do
          {
            "1" => [buffer_response_boundary],
            "5" => [buffer_response_boundary],
            "10" => [buffer_response_boundary],
            "15" => [buffer_response_boundary],
            "20" => [buffer_response_boundary],
            "25" => [buffer_response_boundary],
            "30" => [buffer_response_boundary],
            "35" => [buffer_response_boundary],
            "40" => [buffer_response_boundary],
            "45" => [buffer_response_boundary],
            "50" => [buffer_response_boundary],
            "55" => [buffer_response_boundary],
            "60" => [buffer_response_boundary],
            "70" => [buffer_response_boundary],
            "80" => [buffer_response_boundary],
            "90" => [buffer_response_boundary],
            "100" => [buffer_response_boundary],
            "200" => [buffer_response_boundary],
          }
        end

        before do
          allow(HTTParty).to receive(:get).with(
            "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?bufferSR=3857&"\
            "distances=#{convert_miles_to_metres(ImportPolygons::BUFFER_RADII.first)}&f=json&geodesic=false&geometries=%7B%22geometryType%22%3D%3E%22esriGeometryPolygon%"\
            "22%2C+%22geometries%22%3D%3E%5B%7B%22rings%22%3D%3E%5B%5B%5B51.406361958644%2C+-2.3780576677997%5D%"\
            "2C+%5B51.4063596372237%2C+-2.3787764623145%5D%5D%5D%7D%5D%7D&inSR=4326&outSR=4326&unionResults=true&"\
            "unit=",
          ).and_return(buffer_response)
          ImportPolygons::BUFFER_RADII.each do |distance|
            allow(HTTParty).to receive(:get).with(
              "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?bufferSR=3857&"\
              "distances=#{convert_miles_to_metres(distance)}&f=json&geodesic=false&geometries=%7B%22geometryType%22%3D%3E%22esriGeometryPolygon%22"\
              "%2C+%22geometries%22%3D%3E%5B%7B%22rings%22%3D%3E%5B%5B%5B51.406361958644%2C+-2.3780576677997%5D%2C+%"\
              "5B51.4063596372237%2C+-2.3787764623145%5D%5D%5D%7D%5D%7D&inSR=4326&outSR=4326&unionResults=true&unit=",
            ).and_return(buffer_response)
          end
          subject.call
        end

        it "imports buffers" do
          expect(imported_polygon.buffers).to eq(new_polygons)
        end
      end

      context "when BUFFER_RADII is the same as the last time the task was run" do
        before do
          allow(HTTParty).to receive(:get).with(
            "https://tasks.arcgisonline.com/arcgis/rest/services/Geometry/GeometryServer/buffer?bufferSR=3857&"\
            "distances=#{convert_miles_to_metres(ImportPolygons::BUFFER_RADII.first)}&f=json&geodesic=false&geometries=%7B%22geometryType%22%3D%3E%22esriGeometryPolygon%"\
            "22%2C+%22geometries%22%3D%3E%5B%7B%22rings%22%3D%3E%5B%5B%5B51.406361958644%2C+-2.3780576677997%5D%"\
            "2C+%5B51.4063596372237%2C+-2.3787764623145%5D%5D%5D%7D%5D%7D&inSR=4326&outSR=4326&unionResults=true&"\
            "unit=",
          ).and_return(unchanged_buffers_response)
        end
        it "skips the buffers API call and returns the current buffers" do
          expect(subject).to_not receive(:buffered_polygons)
          expect(imported_polygon.buffers).to eq(original_polygons)
          subject.call
        end
      end

      context "when BUFFER_RADII is different from the last time the task was run" do
        let(:api_location_type) { :regions }
        let(:location_name) { "north east" }
        let(:new_polygons) do
          {
            "1" => [buffer_response_boundary, buffer_response_boundary],
            "2" => [buffer_response_boundary, buffer_response_boundary],
            "99" => [buffer_response_boundary, buffer_response_boundary],
            "100" => [buffer_response_boundary, buffer_response_boundary],
          }
        end

        before do
          stub_const("ImportPolygons::BUFFER_RADII", [1, 2, 99, 100])
          ImportPolygons::BUFFER_RADII.each do |distance|
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

        context "when the length of the params causes the API endpoint length to exceed the maximum" do
          before { stub_const("ImportPolygons::URL_MAXIMUM_LENGTH", 398) }

          it "is still able to import the buffers, by reducing the number of coordinates in the params of the API endpoint" do
            expect(imported_polygon.buffers).to eq(new_polygons)
          end
        end

        context "when the length of the params does not cause the API endpoint length to exceed the maximum" do
          it "imports buffers" do
            expect(imported_polygon.buffers).to eq(new_polygons)
          end
        end
      end
    end
  end
end
