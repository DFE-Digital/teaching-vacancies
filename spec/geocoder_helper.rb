RSpec.configure do |config|
  config.before(:suite) do
    Geocoder.configure(lookup: :test)
  end

  config.before(:each) do
    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'coordinates' => [1, 1],
          'longitude' => '1',
          'latitude' => '1',
        }
      ]
    )
  end

  config.after(:each) do
    Geocoder::Lookup::Test.reset
  end
end
