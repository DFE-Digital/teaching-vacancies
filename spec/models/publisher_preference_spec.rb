require "rails_helper"

RSpec.describe PublisherPreference do
  it { is_expected.to belong_to(:publisher) }
  it { is_expected.to belong_to(:organisation) }
  it { is_expected.to have_many(:organisation_publisher_preferences) }
  it { is_expected.to have_many(:organisations) }
  it { is_expected.to have_many(:local_authority_publisher_schools) }
  it { is_expected.to have_many(:schools) }
end
