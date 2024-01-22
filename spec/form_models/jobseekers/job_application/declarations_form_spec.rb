require "rails_helper"

RSpec.describe Jobseekers::JobApplication::DeclarationsForm, type: :model do
  it { is_expected.to validate_inclusion_of(:close_relationships).in_array(%w[yes no]) }

  context "when close_relationships is yes" do
    before { allow(subject).to receive(:close_relationships).and_return("yes") }

    it { is_expected.to validate_presence_of(:close_relationships_details) }
  end

  it { is_expected.to validate_inclusion_of(:safeguarding_issue).in_array(%w[yes no]) }

  context "when safeguarding_issue is yes" do
    before { allow(subject).to receive(:safeguarding_issue).and_return("yes") }

    it { is_expected.to validate_presence_of(:safeguarding_issue_details) }
  end
end
