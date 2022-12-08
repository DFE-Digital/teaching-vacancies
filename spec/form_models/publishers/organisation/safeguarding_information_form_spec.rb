require "rails_helper"

RSpec.describe Publishers::Organisation::SafeguardingInformationForm, type: :model do
  it { is_expected.to allow_value(Faker::Lorem.sentence(word_count: 99)).for(:safeguarding_information) }
  it { is_expected.not_to allow_value(Faker::Lorem.sentence(word_count: 101)).for(:safeguarding_information) }
  it { is_expected.not_to allow_value("").for(:safeguarding_information) }
end
