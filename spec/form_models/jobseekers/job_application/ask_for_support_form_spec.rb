require "rails_helper"

module Jobseekers
  module JobApplication
    RSpec.describe AskForSupportForm, type: :model do
      subject do
        described_class.new(params.merge(ask_for_support_section_completed: true))
      end

      context "when support_needed is yes" do
        let(:params) { { is_support_needed: "true" } }

        it { is_expected.to validate_presence_of(:support_needed_details) }
      end
    end
  end
end
