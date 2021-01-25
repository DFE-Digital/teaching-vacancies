require "rails_helper"

RSpec.describe Jobseekers::JobApplication::DeclarationsForm, type: :model do
  it { is_expected.to validate_inclusion_of(:banned_or_disqualified).in_array(%w[yes no]) }
  it { is_expected.to validate_inclusion_of(:close_relationships).in_array(%w[yes no]) }
  it { is_expected.to validate_inclusion_of(:right_to_work_in_uk).in_array(%w[yes no]) }

  context "when close_relationships is yes" do
    before { allow(subject).to receive(:close_relationships).and_return("yes") }

    it { is_expected.to validate_presence_of(:close_relationships_details) }
  end
end
