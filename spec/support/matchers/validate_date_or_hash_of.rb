RSpec::Matchers.define :validate_date_or_hash_of do |attribute|
  match do |record|
    # rubocop:disable Layout/HashAlignment
    test_cases = {
      blank:              nil,
      day_as_char:        { 1 => "2025", 2 => "12", 3 => "first" },
      day_out_of_range:   { 1 => "2025", 2 => "12", 3 => "34" },
      month_as_char:      { 1 => "2025", 2 => "jan", 3 => "10" },
      month_out_of_range: { 1 => "2025", 2 => "13", 3 => "10" },
      year_as_char:       { 1 => "this year", 2 => "12", 3 => "10" },
    }
    # rubocop:enable Layout/HashAlignment

    test_cases_results = test_cases.map do |_test_case, value|
      record.errors.clear
      record.send("#{attribute}=", value)
      record.valid?
      record.errors[attribute].present?
    end

    record.errors.clear
    record.send("#{attribute}=", test_cases[:day_out_of_range])
    record.valid?
    keeps_value_when_invalid = record.send(attribute) == test_cases[:day_out_of_range]

    test_cases_results << keeps_value_when_invalid

    test_cases_results.all?
  end

  failure_message do
    "expected #{record.class} to validate date of #{attribute}"
  end

  failure_message_when_negated do
    "expected #{record.class} not to validate date of #{attribute}"
  end

  description do
    "validate date format of #{attribute}"
  end
end
