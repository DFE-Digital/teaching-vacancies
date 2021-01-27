require "rails_helper"

RSpec.describe ImportSchoolDataJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(disable_expensive_jobs_enabled?) }

  context "when DisableExpensiveJobs is not enabled" do
    let(:disable_expensive_jobs_enabled?) { false }

    it "executes perform" do
      import_school_data = double(:mock)
      expect(ImportSchoolData).to receive(:new).and_return(import_school_data)
      expect(import_school_data).to receive(:run!)

      perform_enqueued_jobs { job }
    end
  end

  context "when DisableExpensiveJobs is enabled" do
    let(:disable_expensive_jobs_enabled?) { true }

    it "does not perform the job" do
      expect(ImportSchoolData).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
