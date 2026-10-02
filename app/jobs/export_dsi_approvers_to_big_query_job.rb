# This is loaded correctly by Zeitwerk due to a custom inflection in config/initializers/inflections.rb
require "dfe_sign_in/api"
require "dfe_sign_in/user_rows"
require "big_query/table_sync"

class ExportDSIApproversToBigQueryJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableIntegrations.enabled?

    BigQuery::TableSync.call(
      table: "dsi_approvers",
      key: %i[user_id school_urn trust_uid la_code role_id],
      rows: DfeSignIn::API.approvers.lazy.map { |dsi_row| DfeSignIn::UserRows.new(dsi_row).approver_row },
    )
  end
end
