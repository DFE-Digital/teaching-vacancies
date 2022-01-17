require "rails_helper"

RSpec.describe Publishers::JobListing::EndListingForm, type: :model do
  it { is_expected.to validate_inclusion_of(:hired_status).in_array(Vacancy.hired_statuses.keys) }
  it { is_expected.to validate_inclusion_of(:listed_elsewhere).in_array(Vacancy.listed_elsewheres.keys) }
end
