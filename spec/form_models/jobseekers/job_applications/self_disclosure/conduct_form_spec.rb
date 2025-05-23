require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe ConductForm, type: :model do
    subject(:conduct_form) { described_class.new(params) }

    let(:is_known_to_children_services) { true }
    let(:has_been_dismissed) { true }
    let(:has_been_disciplined) { true }
    let(:has_been_disciplined_by_regulatory_body) { true }
    let(:params) do
      {
        is_known_to_children_services:,
        has_been_dismissed:,
        has_been_disciplined:,
        has_been_disciplined_by_regulatory_body:,
      }
    end

    describe "validation" do
      before { conduct_form.valid? }

      it { is_expected.to be_valid }

      context "when #is_known_to_children_services absent" do
        let(:is_known_to_children_services) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when #has_been_dismissed absent" do
        let(:has_been_dismissed) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when #has_been_disciplined absent" do
        let(:has_been_disciplined) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when #has_been_disciplined_by_regulatory_body absent" do
        let(:has_been_disciplined_by_regulatory_body) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
