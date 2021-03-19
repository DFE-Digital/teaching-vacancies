require "rails_helper"

RSpec.describe Publishers::JobListing::EndListingForm, type: :model do
  it { is_expected.to validate_inclusion_of(:end_listing_reason).in_array(Vacancy.end_listing_reasons.keys) }
  it { is_expected.not_to validate_inclusion_of(:candidate_hired_from).in_array(Vacancy.candidate_hired_froms.keys) }

  context "when `end_listing_reason` is `suitable_candidate_found`" do
    before { allow(subject).to receive(:end_listing_reason).and_return("suitable_candidate_found") }

    it { is_expected.to validate_inclusion_of(:candidate_hired_from).in_array(Vacancy.candidate_hired_froms.keys) }
  end
end
