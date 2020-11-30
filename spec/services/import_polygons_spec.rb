require "rails_helper"

RSpec.describe ImportPolygons do
  subject { described_class.new(location_type: location_type) }
  let(:boundary_endpoint) { LOCATION_POLYGON_SETTINGS[location_type][:boundary_api] }
  let(:boundary_response) { JSON.parse(file_fixture(file_name).read) }

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
        let(:file_name) { "ons_regions.json" }

        it "imports North East region" do
          expect(LocationPolygon.regions.first.name).to eq("north east")
        end

        it "does not import non-existent region" do
          expect(LocationPolygon.regions.count).to eq(1)
        end

        it "imports North East boundaries" do
          expect(LocationPolygon.regions.first.boundary).to eq(boundary_points)
        end
      end

      context "when location type is counties" do
        let(:location_type) { :counties }
        let(:boundary_points) { [52, 0, 52, 0, 52, 0, 52, 0, 52, 0, 52, 0] }
        let(:file_name) { "ons_counties.json" }

        it "imports Essex county" do
          expect(LocationPolygon.counties.first.name).to eq("essex")
        end

        it "does not import non-existent county" do
          expect(LocationPolygon.counties.count).to eq(1)
        end

        it "imports Essex boundaries" do
          expect(LocationPolygon.counties.first.boundary).to eq(boundary_points)
        end
      end

      context "when location type is london boroughs" do
        let(:location_type) { :london_boroughs }
        let(:boundary_points) { [51.5083356630733, 0.00456249603, 51.5051084208278, -0.0057105307948] }
        let(:file_name) { "ons_london_boroughs.json" }

        it "imports Tower Hamlets local authority" do
          expect(LocationPolygon.london_boroughs.first.name).to eq("tower hamlets")
        end

        it "does not import non-existent local authority" do
          expect(LocationPolygon.london_boroughs.count).to eq(1)
        end

        it "imports Tower Hamlets boundaries" do
          expect(LocationPolygon.london_boroughs.first.boundary).to eq(boundary_points)
        end
      end

      context "when location type is cities" do
        let(:location_type) { :cities }
        let(:boundary_points) { [51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145] }
        let(:file_name) { "ons_cities.json" }

        it "imports Bath city" do
          expect(LocationPolygon.cities.first.name).to eq("bath")
        end

        it "does not import non-existent city" do
          expect(LocationPolygon.cities.count).to eq(1)
        end

        it "imports Bath boundaries" do
          expect(LocationPolygon.cities.first.boundary).to eq(boundary_points)
        end
      end
    end

    describe "#get_buffers" do
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

      context "when the length of the params causes the API endpoint length to exceed the maximum" do
        before do
          distances = [5, 10, 15, 20, 25]
          distances.each do |distance|
            allow(HTTParty).to receive(:get).with(
              "https://ons-inspire.esriuk.com/arcgis/rest/services/Utilities/Geometry/GeometryServer/buffer?"\
              "bufferSR=3857&distances=#{convert_miles_to_metres(distance)}&f=json&geodesic=f"\
              "alse&geometries=%7B%22geometryType%22%3D%3E%22esriGeometryPolygon%22%2C+%22geometries%22%3D%3E"\
              "%5B%7B%22rings%22%3D%3E%5B%5B%5B55.8110853660943%2C+-2.0343575091738%5D%2C+%5B55.7647624900862%"\
              "2C+-1.9841097397706%5D%5D%5D%7D%5D%7D&inSR=4326&outSR=4326&unionResults=true&unit=",
            ).and_return(buffer_response)
          end
          subject.call
        end

        let(:location_type) { :regions }
        let(:file_name) { "ons_regions.json" }

        it "imports buffers" do
          expect(LocationPolygon.regions.first.buffers).to eq(imported_buffers)
        end
      end

      context "when the length of the params does not cause the API endpoint length to exceed the maximum" do
        let(:file_name) { "ons_counties.json" }
        let(:location_type) { :counties }

        before do
          stub_const("ImportPolygons::URL_MAXIMUM_LENGTH", 400)
          distances = [5, 10, 15, 20, 25]
          distances.each do |distance|
            allow(HTTParty).to receive(:get).with(
              "https://ons-inspire.esriuk.com/arcgis/rest/services/Utilities/Geometry/GeometryServer/buffer?"\
              "bufferSR=3857&distances=#{convert_miles_to_metres(distance)}&f"\
              "=json&geodesic=false&geometries=%7B%22geometryType%22%3D%3E%22esriGeometryPolygon%22%2C+%22"\
              "geometries%22%3D%3E%5B%7B%22rings%22%3D%3E%5B%5B%5B52%2C+0%5D%2C+%5B52%2C+0%5D%5D%5D%7D%5D%7D"\
              "&inSR=4326&outSR=4326&unionResults=true&unit=",
            ).and_return(buffer_response)
          end
          subject.call
        end

        it "is still able to import the buffers, by reducing the number of coordinates in the params of the API endpoint" do
          expect(LocationPolygon.counties.first.buffers).to eq(imported_buffers)
        end
      end
    end
  end
end
