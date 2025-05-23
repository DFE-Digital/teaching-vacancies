require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe BarredListForm, type: :model do
    subject(:barred_list_form) { described_class.new(params) }

    let(:is_barred) { true }
    let(:has_been_referred) { true }
    let(:params) do
      {
        is_barred:,
        has_been_referred:,
      }
    end

    describe "validation" do
      before { barred_list_form.valid? }

      it { is_expected.to be_valid }

      context "when #is_barred absent" do
        let(:is_barred) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when #has_been_referred absent" do
        let(:has_been_referred) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
