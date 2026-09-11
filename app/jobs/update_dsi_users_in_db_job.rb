# This is loaded correctly by Zeitwerk due to a custom inflection in config/inflections.rb
class UpdateDSIUsersInDbJob < ApplicationJob
  include ActiveJob::Continuable

  queue_as :low

  # Each page just enqueues idempotent per-user upserts (UpdateSingleDSIUserInDbJob), so
  # unlike the BigQuery exports there's no accumulated result that a restart would lose:
  # the cursor can safely skip pages already processed, and re-running the in-flight page
  # after a resume is harmless.
  def perform
    fetch_dsi_users = Publishers::DfeSignIn::FetchDSIUsers.new

    step :sync_users, start: 1 do |step|
      (step.cursor..fetch_dsi_users.dsi_users_page_count).each do |page|
        fetch_dsi_users.dsi_users_page(page).each { |dsi_user| UpdateSingleDSIUserInDbJob.perform_later(dsi_user) }
        step.advance!
      end
    end
  end
end
