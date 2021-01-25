require "rails_helper"

RSpec.describe Publishers::JobListing::SchoolsForm, type: :model do
  subject { described_class.new(params) }

  let(:params) { {} }

  it { is_expected.to validate_presence_of(:organisation_ids) }

  context "when job_location is at_multiple_schools and less than 2 organisations are selected" do
    let(:params) { { job_location: "at_multiple_schools", organisation_ids: [create(:school).id] } }

    it "requires at least 2 schools to be selected" do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:organisation_ids]).to eq([I18n.t("schools_errors.organisation_ids.invalid")])
    end
  end
end
