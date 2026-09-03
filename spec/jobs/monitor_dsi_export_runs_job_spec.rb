require "rails_helper"

RSpec.describe MonitorDSIExportRunsJob do
  subject(:perform) { described_class.perform_now }

  describe "alerting on stale runs" do
    it "alerts when a run has been running for longer than the stale threshold" do
      stale_run = DSIExportRun.create!(source: "users", total_pages: 5,
                                       created_at: (described_class::STALE_AFTER + 1.minute).ago)

      expect(Sentry).to receive(:capture_message).with(
        a_string_matching(/#{stale_run.id}/), hash_including(level: :warning)
      )

      perform
    end

    it "does not alert on a run within the stale threshold" do
      DSIExportRun.create!(source: "users", total_pages: 5,
                           created_at: (described_class::STALE_AFTER - 1.minute).ago)

      expect(Sentry).not_to receive(:capture_message)

      perform
    end

    it "does not alert on a run that has already completed" do
      DSIExportRun.create!(source: "users", total_pages: 5, status: :completed,
                           created_at: (described_class::STALE_AFTER + 1.minute).ago)

      expect(Sentry).not_to receive(:capture_message)

      perform
    end
  end

  describe "cleaning up old runs" do
    it "deletes runs older than the retention period, regardless of status" do
      old_run = DSIExportRun.create!(source: "users", total_pages: 1, status: :completed,
                                     created_at: (described_class::RETENTION_PERIOD + 1.minute).ago)
      old_run.dsi_export_run_pages.create!(page_number: 1, payload: [])

      expect { perform }.to change(DSIExportRun, :count).by(-1)
                                                          .and change(DSIExportRunPage, :count).by(-1)
    end

    it "keeps runs within the retention period" do
      DSIExportRun.create!(source: "users", total_pages: 1, status: :completed,
                           created_at: (described_class::RETENTION_PERIOD - 1.minute).ago)

      expect { perform }.not_to change(DSIExportRun, :count)
    end
  end
end
