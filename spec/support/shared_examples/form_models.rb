RSpec.shared_examples "validates year format" do
  it { is_expected.to allow_value("2010").for(:year) }
  it { is_expected.not_to allow_value("123").for(:year) }
  it { is_expected.not_to allow_value("12345").for(:year) }
  it { is_expected.not_to allow_value("12cd").for(:year) }
end
