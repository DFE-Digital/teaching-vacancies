require "rails_helper"

RSpec.describe Jobseekers::JobApplication::DeclarationsForm, type: :model do
  subject do
    described_class.new(declarations_section_completed: true)
  end

  context "when close_relationships is yes" do
    before { allow(subject).to receive(:has_close_relationships).and_return(true) }

    it { is_expected.to validate_presence_of(:close_relationships_details) }
  end

  context "when safeguarding_issue is yes" do
    before { allow(subject).to receive(:has_safeguarding_issue).and_return(true) }

    it { is_expected.to validate_presence_of(:safeguarding_issue_details) }
  end
end
