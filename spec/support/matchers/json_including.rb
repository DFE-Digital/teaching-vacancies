RSpec::Matchers.define :json_including do |expected_as_hash|
  match do |actual|
    parsed_actual = JSON.parse(actual)
    expected_as_hash.each do |key, value|
      return false unless parsed_actual[key] == value
    end
  end
end
