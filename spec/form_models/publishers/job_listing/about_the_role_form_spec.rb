require "rails_helper"

RSpec.describe Publishers::JobListing::AboutTheRoleForm, type: :model do
  subject { described_class.new(params, vacancy) }

  let(:vacancy) { build_stubbed(:vacancy, :at_one_school, job_role: "teacher") }
  let(:organisation) { build_stubbed(:school) }
  let(:params) { {} }

  it { is_expected.to validate_inclusion_of(:ect_status).in_array(Vacancy.ect_statuses.keys) }
  it { is_expected.to validate_presence_of(:skills_and_experience) }
  it { is_expected.to validate_inclusion_of(:safeguarding_information_provided).in_array([true, false, "true", "false"]) }
  it { is_expected.to validate_inclusion_of(:further_details_provided).in_array([true, false, "true", "false"]) }

  describe "safeguarding information" do
    context "when safeguarding_information_provided is false" do
      before { allow(subject).to receive(:safeguarding_information_provided).and_return("false") }
      it { is_expected.not_to validate_presence_of(:safeguarding_information) }
    end

    context "when safeguarding_information_provided is true" do
      before { allow(subject).to receive(:safeguarding_information_provided).and_return("true") }
      it { is_expected.to validate_presence_of(:safeguarding_information) }
    end
  end

  describe "further details" do
    context "when further_details_provided is false" do
      before { allow(subject).to receive(:further_details_provided).and_return("false") }
      it { is_expected.not_to validate_presence_of(:further_details) }
    end

    context "when further_details_provided is true" do
      before { allow(subject).to receive(:further_details_provided).and_return("true") }
      it { is_expected.to validate_presence_of(:further_details) }
    end
  end

  describe "school offer" do
    let(:params) { { school_offer: school_offer } }

    context "when school offer is not present" do
      let(:school_offer) { nil }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.messages[:school_offer]).to include(I18n.t("about_the_role_errors.school_offer.blank", organisation: "school"))
      end
    end
  end
end
