require "rails_helper"

module Jobseekers
  module JobApplication
    RSpec.describe DeclarationsForm, type: :model do
      subject do
        described_class.new(params.merge(declarations_section_completed: true))
      end

      context "when close_relationships is yes" do
        let(:params) { { has_close_relationships: "true" } }

        it { is_expected.to validate_presence_of(:close_relationships_details) }
      end

      context "when safeguarding_issue is yes" do
        let(:params) { { has_safeguarding_issue: "true" } }

        it { is_expected.to validate_presence_of(:safeguarding_issue_details) }
      end

      context "when have lived abroad" do
        let(:params) { { has_lived_abroad: "true" } }

        it { is_expected.to validate_presence_of(:life_abroad_details) }
      end
    end
  end
end
