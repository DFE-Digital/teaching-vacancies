require "rails_helper"

RSpec.describe Jobseekers::JobApplication::ReviewForm, type: :model do
  let(:completed_steps) { [] }

  subject do
    described_class.new({ confirm_data_accurate: "1", confirm_data_usage: "1", completed_steps: completed_steps })
  end

  it { is_expected.to validate_acceptance_of(:confirm_data_accurate) }
  it { is_expected.to validate_acceptance_of(:confirm_data_usage) }

  context "when all steps are complete" do
    let(:completed_steps) { JobApplication.completed_steps.keys }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when there are incomplete steps" do
    let(:completed_steps) { %w[personal_details employment_history] }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end
end
