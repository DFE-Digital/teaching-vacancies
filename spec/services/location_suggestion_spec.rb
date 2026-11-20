require "rails_helper"

RSpec.describe LocationSuggestion, :geocode do
  subject(:suggestion) { described_class.new(location_input) }

  let(:suggestions) { suggestion.suggest_locations.first }
  let(:eastings) { (401_000..).step(1_000).each }
  let(:os_url) { %r{api\.os\.uk/search/names/v1/find} }
  let(:os_entries) { [] }
  let!(:os_stub) { stub_request(:get, os_url).to_return(status: 200, body: os_body(os_entries)) }

  def os_body(entries)
    { header: { totalresults: entries.size }, results: entries.map { |entry| { "GAZETTEER_ENTRY" => entry } } }.to_json
  end

  # A place with a bounding box of `size` metres a side, by default 1 km east of the previous one.
  def place(name, local_type, easting: next_easting, northing: 200_000, size: 1_000, country: "England", **fields)
    { "NAME1" => name,
      "LOCAL_TYPE" => local_type,
      "COUNTRY" => country,
      "GEOMETRY_X" => easting,
      "GEOMETRY_Y" => northing,
      "MBR_XMIN" => easting,
      "MBR_YMIN" => northing,
      "MBR_XMAX" => easting + size,
      "MBR_YMAX" => northing + size }.merge(fields.transform_keys(&:to_s).transform_keys(&:upcase))
  end

  def next_easting
    eastings.next
  end

  describe "#initialize" do
    let(:location_input) { "any" }

    it "raises MissingLocationInput error when called with nil location_input" do
      expect { described_class.new(nil) }.to raise_error(described_class::MissingLocationInput)
    end

    it "raises InsufficientLocationInput error when called with location_input less than 3 characters" do
      expect { described_class.new("l") }.to raise_error(described_class::InsufficientLocationInput)
    end
  end

  describe "#suggest_locations" do
    context "when Ordnance Survey returns places" do
      let(:location_input) { "Clap" }
      let(:os_entries) do
        [
          place("Clap Hill", "Village", district_borough: "Folkestone and Hythe", county_unitary: "Kent"),
          place("Clay Hills", "Village", county_unitary: "Essex"),
          place("Clapham", "Village", county_unitary: "Bedford", size: 2_000),
          place("Clapham Park", "Suburban Area", district_borough: "Lambeth", county_unitary: "Greater London", region: "London"),
          # The API can return the same place twice.
          place("Clapham", "Other Settlement", easting: 529_697, district_borough: "Lambeth", county_unitary: "Greater London", region: "London"),
          place("Clapham", "Other Settlement", easting: 529_697, district_borough: "Lambeth", county_unitary: "Greater London", region: "London"),
          place("Clapham", "Hamlet", district_borough: "Teignbridge", county_unitary: "Devon"),
          place("Clapton", "Town", country: "Wales"),
        ]
      end

      it "suggests the places starting with the search, most prominent first, labelled so that Geocoding picks each" do
        expect(suggestions).to eq(["Clapham, London", "Clapham Park, London", "Clapham, Bedford", "Clap Hill, Folkestone and Hythe", "Clapham, Teignbridge"])
      end

      it "returns the name of each suggestion as its matched term" do
        expect(suggestion.suggest_locations.last.first(2)).to eq([["Clapham"], ["Clapham Park"]])
      end

      it "searches Ordnance Survey for places only, with as many results as it allows" do
        suggestions
        expect(os_stub.with(query: hash_including("query" => "Clap", "maxresults" => "100",
                                                  "fq" => "local_type:City local_type:Town local_type:Suburban_Area local_type:Village local_type:Other_Settlement local_type:Hamlet")))
          .to have_been_requested
      end
    end

    context "when a word after the first starts with the search" do
      let(:location_input) { "leam" }
      let(:os_entries) do
        [
          place("Royal Leamington Spa", "Town", district_borough: "Warwick", county_unitary: "Warwickshire"),
          place("Little Leam", "Village", county_unitary: "Kent"),
        ]
      end

      it "suggests towns and suburbs, but not villages or hamlets" do
        expect(suggestions).to eq(["Royal Leamington Spa, Warwick"])
      end
    end

    context "when the district repeats the place's name" do
      let(:location_input) { "Ashford" }
      let(:os_entries) { [place("Ashford", "Town", district_borough: "Ashford", county_unitary: "Kent")] }

      it "uses the county" do
        expect(suggestions).to eq(["Ashford, Kent"])
      end
    end

    context "when two places with the name in the same district would rank the same" do
      let(:location_input) { "Blackpool" }
      let(:os_entries) do
        [
          place("Blackpool", "Hamlet", easting: 256_537, district_borough: "South Hams", county_unitary: "Devon", region: "South West"),
          place("Blackpool", "Hamlet", easting: 256_900, district_borough: "South Hams", county_unitary: "Devon", region: "South West"),
          place("Blackpool", "Town", county_unitary: "Blackpool", region: "North West"),
        ]
      end

      it "suggests neither, and qualifies another place with its region when its county repeats the name" do
        expect(suggestions).to eq(["Blackpool, North West"])
      end
    end

    context "when the search has a qualifier after a comma" do
      let(:location_input) { "Clapham, Lon" }
      let(:os_entries) do
        [
          place("Clapham", "Other Settlement", district_borough: "Lambeth", county_unitary: "Greater London", region: "London"),
          place("Clapham", "Village", county_unitary: "Bedford"),
        ]
      end

      it "keeps the suggestions continuing it" do
        expect(suggestions).to eq(["Clapham, London"])
      end
    end

    context "when an area we hold a polygon for starts with the search" do
      let(:location_input) { "Brigh" }
      let(:os_entries) do
        [
          place("Brighton", "Other Settlement", easting: 531_272, northing: 104_189, county_unitary: "The City of Brighton and Hove"),
          place("Brightlingsea", "Town", district_borough: "Tendring", county_unitary: "Essex"),
        ]
      end

      before { create(:location_polygon, name: "brighton and hove", centroid: "POINT(-0.1372 50.8429)") }

      it "suggests the area first, instead of the place it is named after" do
        expect(suggestions).to eq(["Brighton and Hove", "Brightlingsea, Tendring"])
      end
    end

    context "when an area named after a place has no centre" do
      let(:location_input) { "Brigh" }
      let(:os_entries) do
        [place("Brighton", "Other Settlement", easting: 531_272, northing: 104_189, county_unitary: "The City of Brighton and Hove")]
      end

      before { create(:location_polygon, name: "brighton and hove", centroid: nil) }

      it "suggests both" do
        expect(suggestions).to eq(["Brighton and Hove", "Brighton, The City of Brighton and Hove"])
      end
    end

    context "when an area has a word starting with the search" do
      let(:location_input) { "Yorks" }

      before do
        create(:location_polygon, name: "north yorkshire")
        create(:location_polygon, name: "yorkshire and the humber")
      end

      it "suggests areas whose name starts with the search first" do
        expect(suggestions).to eq(["Yorkshire and the Humber", "North Yorkshire"])
      end
    end

    context "when the search, as typed, names an area another area would be listed before" do
      let(:location_input) { "Kingston" }

      before do
        create(:location_polygon, name: "kingston upon hull")
        create(:location_polygon, name: "kingston upon thames")
      end

      it "suggests the area the search goes to first" do
        expect(suggestions).to eq(["Kingston upon Thames", "Kingston upon Hull"])
      end
    end

    context "when the search, as typed, names an area we have no display name for" do
      let(:location_input) { "Foobarton " }

      before { create(:location_polygon, name: "foobarton") }

      it "suggests the search as typed" do
        expect(suggestions).to eq(%w[Foobarton])
      end
    end

    context "when the search, as typed, finds a place that would be listed after an area" do
      let(:location_input) { "Durham" }
      let(:os_entries) { [place("Durham", "City", county_unitary: "County Durham")] }

      before { create(:location_polygon, name: "county durham, darlington, hartlepool and stockton") }

      it "suggests the place the search goes to first" do
        expect(suggestions).to eq(["Durham, County Durham", "County Durham"])
      end
    end

    context "when the search, as typed, finds a place that is a suggested area" do
      let(:location_input) { "Weston" }
      let(:os_entries) do
        [place("Weston-super-Mare", "Town", easting: 332_000, northing: 161_000, county_unitary: "North Somerset")]
      end

      before { create(:location_polygon, name: "weston-super-mare", centroid: "POINT(-2.9707 51.3459)") }

      it "suggests the area only" do
        expect(suggestions).to eq(%w[Weston-Super-Mare])
      end
    end

    context "when the search, as typed, finds a place no qualifier tells apart" do
      let(:location_input) { "Testcombe" }
      let(:os_entries) do
        [
          place("Testcombe", "Hamlet", district_borough: "Mid Devon", county_unitary: "Devon", region: "South West"),
          place("Testcombe", "Hamlet", district_borough: "Mid Devon", county_unitary: "Devon", region: "South West"),
        ]
      end

      it "suggests nothing" do
        expect(suggestions).to be_empty
      end
    end

    context "when the search looks like the start of a postcode" do
      let(:location_input) { "sw4 0a" }
      let(:os_entries) do
        [
          place("SW4 0AA", "Postcode"),
          place("SW4 0AB", "Postcode"),
          place("SW4 0BA", "Postcode"),
          place("CF4 0AA", "Postcode", country: "Wales"),
        ]
      end

      it "suggests the postcodes in England starting with it" do
        expect(suggestions).to eq(["SW4 0AA", "SW4 0AB"])
        expect(os_stub.with(query: hash_including("query" => "sw4 0a", "fq" => "local_type:Postcode"))).to have_been_requested
      end
    end

    context "when Ordnance Survey fails" do
      let(:location_input) { "Clap" }

      before { stub_request(:get, os_url).to_return(status: 500, body: "") }

      it "suggests nothing, and logs only the error class" do
        allow(Rails.logger).to receive(:error)
        allow(Geocoder).to receive(:search).and_raise(Geocoder::ServiceUnavailable, "https://api.os.uk/search/names/v1/find?key=secret")

        expect(suggestions).to be_empty
        expect(Rails.logger).to have_received(:error).with("Ordnance Survey Names API location suggestion failed: Geocoder::ServiceUnavailable")
      end
    end

    context "when there is no Ordnance Survey API key" do
      let(:location_input) { "Clap" }

      before { allow(Geocoder).to receive(:config_for_lookup).with(:uk_ordnance_survey_names).and_return({ api_key: "" }) }

      it "suggests nothing, without calling Ordnance Survey" do
        expect(suggestions).to be_empty
        expect(os_stub).not_to have_been_requested
      end
    end
  end
end
