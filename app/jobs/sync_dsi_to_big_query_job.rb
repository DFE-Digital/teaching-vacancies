require "dfe_sign_in/api"
require "dfe_sign_in/user_rows"
require "big_query/table_sync"
require "google/cloud/bigquery"

class SyncDSIToBigQueryJob < ApplicationJob
  queue_as :low

  TABLES = {
    users: {
      table: "dsi_users",
      key: %i[user_id school_urn trust_uid la_code],
      source: -> { DfeSignIn::API.users },
      mapper: ->(dsi_row) { DfeSignIn::UserRows.for_users(dsi_row) },
    },
    approvers: {
      table: "dsi_approvers",
      key: %i[user_id school_urn trust_uid la_code role_id],
      source: -> { DfeSignIn::API.approvers },
      mapper: ->(dsi_row) { DfeSignIn::UserRows.for_approvers(dsi_row) },
    },
  }.freeze

  def perform(table_name)
    return if DisableIntegrations.enabled?

    config = TABLES.fetch(table_name.to_sym) { raise ArgumentError, "unknown DSI sync table: #{table_name}" }

    BigQuery::TableSync.call(
      dataset: bigquery_dataset,
      table: config[:table],
      key: config[:key],
      rows: config[:source].call.lazy.map { |dsi_row| config[:mapper].call(dsi_row) },
    )
  rescue StandardError => e
    Rails.logger.warn("DSI sync failed for #{table_name}: #{e.message}")
    raise
  end

  private

  def bigquery_dataset
    Google::Cloud::Bigquery.new.dataset(Rails.configuration.bigquery_dataset)
  end
end
