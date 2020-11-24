require "rails_helper"

RSpec.describe Publisher, type: :model do
  describe "#accepted_terms_and_conditions?" do
    subject { user.accepted_terms_and_conditions? }

    context "has accepted terms and conditions" do
      let(:user) { create(:publisher, accepted_terms_at: Time.current) }

      it { is_expected.to be true }
    end
    context "has not accepted terms and conditions" do
      let(:user) { create(:publisher, accepted_terms_at: nil) }

      it { is_expected.to be false }
    end
  end
end
