require 'rails_helper'
require 'geocoding'

RSpec.describe Geocoding do
  before do
    require 'geocoder'
    Geocoder.configure(lookup: :test)
  end

  context 'Retrieving the coordinates for a postcode' do
    it 'returns the correct value when the input is a valid postcode' do
      Geocoder::Lookup::Test.add_stub(
        'TS14 6RD', [
          {
            'coordinates' => [-1.04577, 54.541098],
            'longitude' => '-1.04577',
            'latitude' => '54.541098',
          }
        ]
      )
      geocoding = Geocoding.new('TS14 6RD')
      expect(geocoding.coordinates).to eq([-1.04577, 54.541098])
    end

    it 'returns [0,0] when the input is invalid' do
      Geocoder::Lookup::Test.add_stub('TS14', [{}])

      geocoding = Geocoding.new('TS14')
      expect(geocoding.coordinates).to eq([0, 0])
    end
  end
end
