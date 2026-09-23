# This is loaded correctly by Zeitwerk due to a custom inflection in config/initializers/inflections.rb
require "dfe_sign_in/api"
require "dfe_sign_in/user_rows"
require "big_query/table_sync"

class ExportDSIUsersToBigQueryJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableIntegrations.enabled?

    BigQuery::TableSync.call(
      table: "dsi_users",
      key: %i[user_id school_urn trust_uid la_code],
      rows: DfeSignIn::API.users.lazy.map { |dsi_row| DfeSignIn::UserRows.new(dsi_row).user_row },
    )
  end
end
