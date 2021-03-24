require "rails_helper"

RSpec.describe OrganisationPublisherPreference do
  it { is_expected.to belong_to(:organisation) }
  it { is_expected.to belong_to(:publisher_preference) }
end
