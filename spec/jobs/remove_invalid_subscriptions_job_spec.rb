require "rails_helper"

RSpec.describe RemoveInvalidSubscriptionsJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(disable_expensive_jobs_enabled?) }

  context "when DisableExpensiveJobs is not enabled" do
    let(:disable_expensive_jobs_enabled?) { false }

    it "queues the job" do
      expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it "is in the remove_invalid_subscriptions queue" do
      expect(job.queue_name).to eq("remove_invalid_subscriptions")
    end

    it "executes perform" do
      expect(RemoveInvalidSubscriptions).to receive_message_chain(:new, :run!)
      perform_enqueued_jobs { job }
    end
  end

  context "when DisabledExpensiveJobs is enabled" do
    let(:disable_expensive_jobs_enabled?) { true }

    it "does not perform the job" do
      expect(RemoveInvalidSubscriptions).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
