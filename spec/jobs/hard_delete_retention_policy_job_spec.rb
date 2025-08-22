require "rails_helper"

RSpec.describe HardDeleteRetentionPolicyJob do
  let(:job) { described_class.new }

  describe ".threshold" do
    subject(:threshold) { job.threshold }

    it { expect(threshold.to_fs).to eq(5.years.ago.to_fs) }
  end

  describe ".perform" do
    let(:over_5_years_ago) { 5.years.ago - 1.day }
    let!(:target_model) { create(:job_application, :status_submitted, submitted_at: over_5_years_ago) }

    before { described_class.perform_now }

    it "destroys model" do
      expect { target_model.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".hard_delete?" do
    it { expect(job).to be_hard_delete }
  end
end
