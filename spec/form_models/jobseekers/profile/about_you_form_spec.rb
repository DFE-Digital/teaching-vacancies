require "rails_helper"

RSpec.describe Jobseekers::Profile::AboutYouForm, type: :model do
  it { is_expected.to allow_value(Faker::Lorem.sentence(word_count: 1000)).for(:about_you) }
  it { is_expected.not_to allow_value(Faker::Lorem.sentence(word_count: 1001)).for(:about_you) }
  it { is_expected.not_to allow_value("").for(:about_you) }
end
