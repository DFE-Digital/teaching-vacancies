RSpec::Matchers.define :anonymised_form_of do |str|
  match do |actual|
    actual == StringAnonymiser.new(str).to_s
  end
end
