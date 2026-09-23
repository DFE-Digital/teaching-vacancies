require "dfe_sign_in/api"

# This is loaded correctly by Zeitwerk due to a custom inflection in config/initializers/inflections.rb
class UpdateDSIUsersInDbJob < ApplicationJob
  queue_as :low

  # Enqueues one idempotent per-user upsert (UpdateSingleDSIUserInDbJob) per DSI user. Unlike
  # the BigQuery sync, there's no accumulated result an interruption could leave half-done —
  # if this job is restarted, re-enqueuing users already processed is harmless rather than
  # something worth checkpointing around.
  def perform
    DfeSignIn::API.users.each { |dsi_user| UpdateSingleDSIUserInDbJob.perform_later(dsi_user) }
  end
end
