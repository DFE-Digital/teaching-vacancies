require "rails_helper"

RSpec.describe Publishers::JobListing::JobLocationForm, type: :model do
  it { is_expected.to validate_presence_of(:organisation_ids) }
end
