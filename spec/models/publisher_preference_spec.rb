require "rails_helper"

RSpec.describe PublisherPreference, type: :model do
  it { is_expected.to belong_to(:publisher) }
  it { is_expected.to belong_to(:organisation) }
end
