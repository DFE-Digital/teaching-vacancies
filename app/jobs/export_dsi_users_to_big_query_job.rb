# This is loaded correctly by Zeitwerk due to a custom inflection in config/inflections.rb
class ExportDSIUsersToBigQueryJob < ApplicationJob
  queue_as :low

  # Fans out one FetchDSIUsersExportPageJob per page instead of fetching every page
  # serially in this job. The live BigQuery table is only replaced once every page has
  # arrived (see FinalizeDSIUsersExportJob), so a page that keeps failing leaves the table
  # untouched instead of failing the whole export.
  def perform
    return if DisableIntegrations.enabled?
    # A previous run that hasn't finished (e.g. stuck on a permanently failing page) must
    # not overlap with today's: two runs finalizing at once could race to replace the table.
    return if DSIExportRun.exists?(source: "users", status: %i[running finalizing])

    fetch = Publishers::DfeSignIn::FetchDSIUsers.new
    run = DSIExportRun.create!(source: "users", total_pages: fetch.dsi_users_page_count)

    (1..run.total_pages).each { |page| FetchDSIUsersExportPageJob.perform_later(run.id, page) }
  end
end
