require "rails_helper"

RSpec.describe SoftDeleteRetentionPolicyJob do
  let(:job) { described_class.new }

  describe ".threshold" do
    subject(:threshold) { job.threshold }

    it { expect(threshold.to_fs).to eq(6.months.ago.to_fs) }
  end

  describe ".perform" do
    let(:over_6_months_ago) { 6.months.ago - 1.day }
    let!(:target_model) { create(:job_application, :status_submitted, submitted_at: over_6_months_ago) }

    before { described_class.perform_now }

    it "does not destroy the model" do
      expect { target_model.reload }.not_to raise_error
    end

    it "discards model" do
      expect(target_model.reload).to be_discarded
    end
  end

  describe ".hard_delete?" do
    it { expect(job).not_to be_hard_delete }
  end
end
