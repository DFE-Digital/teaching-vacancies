require "rails_helper"

RSpec.describe Geocoding do
  context "Retrieving the coordinates for a postcode" do
    context "When using the Redis cache with network calls" do
      let(:request_url) do
        "https://api.ordnancesurvey.co.uk/opennames/v1/find?fq=local_type%3ACity+local_type%3AHamlet+local_type%3AOther_Settlement+local_type%3ATown+local_type%3AVillage+local_type%3APostcode&key=&query=TS14+6RD"
      end

      let(:cache_key) do
        request_url_without_key = request_url.sub("&key=", "")
        "geocoder:#{request_url_without_key}"
      end

      let(:os_api_response) { { header: { totalresults: 0 } }.to_json }
      let(:key_doesnt_exist) { -2 }

      before(:all) do
        Geocoder.configure(lookup: :uk_ordnance_survey_names)
      end

      after(:all) do
        Geocoder.configure(lookup: :test)
      end

      before do
        Geocoder.configure(api_key: "")
        stub_request(:get, request_url)
          .to_return(status: 200, body: os_api_response, headers: {})
      end

      after do
        Redis::Objects.redis.flushdb
      end

      let(:geocoding) do
        Geocoding.new("TS14 6RD")
      end

      subject do
        geocoding.coordinates
      end

      it "caches the API response with a TTL of 26 hours" do
        expect { subject }.to change { Redis::Objects.redis.ttl(cache_key) }.from(key_doesnt_exist).to(26.hours.to_i)
      end

      it "caches the API response" do
        expect { subject }.to change { Redis::Objects.redis.get(cache_key) }.from(nil).to(os_api_response)
      end
    end

    context "When not using the Redis cache" do
      it "returns the correct value when the input is a valid postcode" do
        geocoding = Geocoding.new("TS14 6RD")
        expect(geocoding.coordinates).to eq(Geocoder::DEFAULT_STUB_COORDINATES)
      end

      it "returns [0,0] when the input is invalid" do
        Geocoder::Lookup::Test.add_stub("TS14", [{}])

        geocoding = Geocoding.new("TS14")
        expect(geocoding.coordinates).to eq([0, 0])
      end
    end
  end
end
