require "rails_helper"

RSpec.describe Publishers::OrganisationForm, type: :model do
  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com").for(:website) }
  it { is_expected.to allow_value("").for(:website) }
  it { is_expected.not_to allow_value("invalid_website").for(:website) }
end
