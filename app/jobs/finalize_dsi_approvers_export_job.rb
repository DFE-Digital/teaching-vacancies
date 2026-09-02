# This is loaded correctly by Zeitwerk due to a custom inflection in config/inflections.rb
class FinalizeDSIApproversExportJob < ApplicationJob
  queue_as :low

  def perform(run_id)
    # Guards against the race where the last two pages to arrive both see
    # `all_pages_received?` true and both enqueue this job: only the first claims the run.
    claimed = DSIExportRun.running.where(id: run_id).update_all(status: DSIExportRun.statuses[:finalizing])
    return if claimed.zero?

    run = DSIExportRun.find(run_id)

    unless run.all_pages_received?
      run.failed!
      raise "DSIExportRun #{run_id} (approvers) finalized without all pages present " \
            "(#{run.dsi_export_run_pages.count}/#{run.total_pages})"
    end

    pages = run.dsi_export_run_pages.order(:page_number).pluck(:payload)
    Publishers::DfeSignIn::BigQueryExport::Approvers.new.insert_pages(pages)

    run.completed!
    run.dsi_export_run_pages.delete_all
  end
end
