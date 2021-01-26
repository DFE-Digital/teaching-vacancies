require "rails_helper"

RSpec.describe Publishers::JobListing::JobLocationForm, type: :model do
  it { is_expected.to validate_presence_of(:job_location) }
end
