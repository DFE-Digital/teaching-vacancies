# This is loaded correctly by Zeitwerk due to a custom inflection in config/inflections.rb
class UpdateDSIUsersInDbJob < ApplicationJob
  queue_as :low

  # Fans out one FetchDSIUsersPageJob per page instead of fetching every page serially in
  # this job: a page that keeps failing only holds up that page, and pages fetch in
  # parallel (bounded by the low queue's worker threads and FetchDSIUsersPageJob's own
  # concurrency limit) instead of one at a time.
  def perform
    # A previous run that hasn't finished (e.g. stuck on a permanently failing page) must
    # not overlap with today's: it would double up DSI requests and page-processing jobs.
    return if DSIExportRun.exists?(source: "db_sync", status: %i[running finalizing])

    fetch_dsi_users = Publishers::DfeSignIn::FetchDSIUsers.new
    run = DSIExportRun.create!(source: "db_sync", total_pages: fetch_dsi_users.dsi_users_page_count)

    (1..run.total_pages).each { |page| FetchDSIUsersPageJob.perform_later(run.id, page) }
  end
end
