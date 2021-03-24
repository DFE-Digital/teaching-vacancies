require "rails_helper"

RSpec.describe ImportPolygonDataJob do
  subject(:job) { described_class.perform_later }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(disable_expensive_jobs_enabled?) }

  context "when DisableExpensiveJobs is not enabled" do
    let(:disable_expensive_jobs_enabled?) { false }

    it "executes perform" do
      import_polygon_data = double(:mock)
      expect(ImportPolygons).to receive(:new).and_return(import_polygon_data).exactly(3).times
      expect(import_polygon_data).to receive(:call).exactly(3).times

      perform_enqueued_jobs { job }
    end
  end

  context "when DisableExpensiveJobs is enabled" do
    let(:disable_expensive_jobs_enabled?) { true }

    it "does not perform the job" do
      expect(ImportPolygons).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
