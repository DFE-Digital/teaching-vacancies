# This is loaded correctly by Zeitwerk due to a custom inflection in config/inflections.rb
#
# The fan-out designs (see ExportDSIUsersToBigQueryJob, UpdateDSIUsersInDbJob) fail safe: a
# page that keeps failing just leaves its DSIExportRun stuck at "running"/"finalizing"
# forever rather than raising anywhere, since for the BigQuery exports the whole point is to
# never touch the live table without a complete set of pages. That safety is silent by
# default, so this job is what actually tells a human a run never completed.
class MonitorDSIExportRunsJob < ApplicationJob
  queue_as :low

  # Generous relative to a single page's own retry budget (~75 minutes, see
  # ApplicationJob), since several pages can be retrying independently in the same run.
  STALE_AFTER = 3.hours
  # Runs are pure bookkeeping with no value once superseded by the next day's run.
  RETENTION_PERIOD = 3.days

  def perform
    alert_stale_runs
    DSIExportRun.where(created_at: ...RETENTION_PERIOD.ago).destroy_all
  end

  private

  def alert_stale_runs
    DSIExportRun.where(status: %i[running finalizing], created_at: ...STALE_AFTER.ago).find_each do |run|
      Sentry.capture_message(
        "DSIExportRun #{run.id} (#{run.source}) has been #{run.status} for over #{STALE_AFTER.inspect}: " \
        "a page is likely stuck retrying, and this run has not completed today",
        level: :warning,
        fingerprint: ["dsi_export_run_stale", run.source],
      )
    end
  end
end
