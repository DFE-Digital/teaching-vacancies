require "rails_helper"

RSpec.describe LocationSuggestion do
  subject { described_class.new(location_input) }

  let(:location_input) { "plac" }

  describe "#initialize" do
    it "raises MissingLocationInput error when called with nil location_input" do
      expect { described_class.new(nil) }.to raise_error(described_class::MissingLocationInput)
    end

    it "raises InsufficientLocationInput error when called with location_input less than 3 characters" do
      expect { described_class.new("l") }.to raise_error(described_class::InsufficientLocationInput)
    end
  end

  describe "#get_suggestions_from_google" do
    let(:predictions) { [] }
    let(:request_body) { { predictions: }.to_json }
    let(:request_status) { 200 }
    let(:request_url) { "https://google_endpoint.google/magic_endpoint" }
    let(:query_hash) { { key: "test_key", input: location_input } }

    before do
      allow(subject).to receive(:request_url).and_return(request_url)
      allow(subject).to receive(:build_google_query).and_return(query_hash)
      stub_request(:get, request_url).to_return(body: request_body, status: request_status)
    end

    context "the request is unsuccessful" do
      let(:request_status) { 400 }

      it "raises a HTTParty::ResponseError" do
        expect { subject.send(:get_suggestions_from_google) }.to raise_error do
          HTTParty::ResponseError.new("Something went wrong")
        end
      end
    end

    context "the response contains an error message" do
      let(:error_message) { "This is an error" }
      let(:request_body) { { error_message: }.to_json }

      it "raises a GooglePlacesAutocompleteError" do
        expect { subject.send(:get_suggestions_from_google) }.to raise_error do
          described_class::GooglePlacesAutocompleteError.new("Something went wrong")
        end
      end
    end

    context "the request is successful" do
      it "returns the correct response" do
        expect(subject.send(:get_suggestions_from_google)).to eq(JSON.parse(request_body))
      end
    end
  end

  describe "#suggestion_locations" do
    let(:parsed_response) { { predictions: }.deep_stringify_keys }
    let(:predictions) do
      [
        { description: "place, region, UK",
          terms: [{ offset: 0, value: "place" }, { offset: 5, value: "UK" }] },
        { description: "different_place, region, UK",
          terms: [{ offset: 0, value: "different_place" }, { offset: 5, value: "UK" }] },
      ]
    end

    let(:suggestions) { ["place, region, UK", "different_place, region, UK"] }
    let(:matched_terms) { [%w[place], %w[different_place]] }

    before do
      allow(subject).to receive(:get_suggestions_from_google).and_return(parsed_response)
    end

    it "returns the parsed data" do
      expect(subject.suggest_locations).to eq([suggestions, matched_terms])
    end
  end
end
