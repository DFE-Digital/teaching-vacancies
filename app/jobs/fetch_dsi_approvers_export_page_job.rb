# This is loaded correctly by Zeitwerk due to a custom inflection in config/inflections.rb
class FetchDSIApproversExportPageJob < ApplicationJob
  queue_as :low

  # Caps how many pages are fetched from DSI at once across all pods, so fanning this out
  # doesn't turn into dozens of simultaneous requests hitting their API. Retries (via
  # ApplicationJob's retry_on) are per page: a page that keeps failing never enqueues
  # FinalizeDSIApproversExportJob, so the live table is simply never replaced for this run.
  limits_concurrency to: 5, key: :fetch_dsi_approvers_export_page, duration: 10.minutes

  def perform(run_id, page)
    run = DSIExportRun.find(run_id)
    approvers = Publishers::DfeSignIn::FetchDSIUsers.new.dsi_approvers_page(page)

    DSIExportRunPage.find_or_create_by!(dsi_export_run: run, page_number: page) do |run_page|
      run_page.payload = approvers
    end

    FinalizeDSIApproversExportJob.perform_later(run.id) if run.reload.all_pages_received?
  end
end
