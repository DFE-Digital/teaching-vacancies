require "rails_helper"

RSpec.describe Publishers::JobListing::JobRoleDetailsForm, type: :model do
  subject { described_class.new(vacancy: vacancy) }

  context "when main job role is teacher" do
    let(:vacancy) { build(:vacancy, :teacher) }

    it { is_expected.to validate_inclusion_of(:ect_status).in_array(Vacancy.ect_statuses.keys) }
  end
end
