require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe ConfirmationForm, type: :model do
    subject(:confirmation_form) { described_class.new(params) }

    let(:agreed_for_processing) { true }
    let(:agreed_for_criminal_record) { true }
    let(:agreed_for_organisation_update) { true }
    let(:agreed_for_information_sharing) { true }
    let(:params) do
      {
        agreed_for_processing:,
        agreed_for_criminal_record:,
        agreed_for_organisation_update:,
        agreed_for_information_sharing:,
      }
    end

    describe "validation" do
      before { confirmation_form.valid? }

      it { is_expected.to be_valid }

      context "when #agreed_for_processing absent" do
        let(:agreed_for_processing) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when #agreed_for_criminal_record absent" do
        let(:agreed_for_criminal_record) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when #agreed_for_organisation_update absent" do
        let(:agreed_for_organisation_update) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when #agreed_for_information_sharing absent" do
        let(:agreed_for_information_sharing) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
