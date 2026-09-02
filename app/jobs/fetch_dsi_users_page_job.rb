# This is loaded correctly by Zeitwerk due to a custom inflection in config/inflections.rb
class FetchDSIUsersPageJob < ApplicationJob
  queue_as :low

  # Caps how many pages are fetched from DSI at once across all pods, so fanning this out
  # doesn't turn into dozens of simultaneous requests hitting their API. Retries (via
  # ApplicationJob's retry_on) are per page, so a page that keeps failing no longer holds up
  # or restarts pages that already succeeded.
  limits_concurrency to: 5, key: :fetch_dsi_users_page, duration: 10.minutes

  def perform(run_id, page)
    run = DSIExportRun.find(run_id)

    Publishers::DfeSignIn::FetchDSIUsers.new.dsi_users_page(page).each do |dsi_user|
      UpdateSingleDSIUserInDbJob.perform_later(dsi_user)
    end

    # No payload worth caching here (unlike the BigQuery export pages): each user is
    # already applied above. This row only exists to mark the page as done.
    DSIExportRunPage.find_or_create_by!(dsi_export_run: run, page_number: page) { |run_page| run_page.payload = [] }

    run.completed! if run.reload.all_pages_received?
  end
end
