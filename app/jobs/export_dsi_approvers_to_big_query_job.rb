# This is loaded correctly by Zeitwerk due to a custom inflection in config/initializers/inflections.rb
require "dfe_sign_in/api"
require "big_query/table"
require "big_query/table_sync"

class ExportDSIApproversToBigQueryJob < ApplicationJob
  include Publishers::DfeSignIn::BigQueryExport

  queue_as :low

  def perform
    return if DisableIntegrations.enabled?

    BigQuery::TableSync.call(
      table: BigQuery::Table.new("dsi_approvers", key: %i[user_id school_urn trust_uid la_code role_id], schema: method(:define_schema)),
      rows: DfeSignIn::API.approvers.map { |approver| big_query_row(approver) },
    )
  end

  private

  def big_query_row(approver)
    {
      email: approver["email"],
      family_name: approver["familyName"],
      given_name: approver["givenName"],
      la_code: integer(la_code(approver)),
      trust_uid: integer(approver.dig("organisation", "uid")),
      role_id: approver["roleId"],
      role_name: approver["roleName"],
      school_urn: integer(approver.dig("organisation", "urn")),
      user_id: approver["userId"],
    }
  end

  def define_schema(schema)
    schema.string "email", mode: :required, policy_tags: [POLICY_TAG_MASKED]
    schema.string "family_name", mode: :required, policy_tags: [POLICY_TAG_MASKED]
    schema.string "given_name", mode: :required, policy_tags: [POLICY_TAG_MASKED]
    schema.integer "la_code", mode: :nullable
    schema.string "role_id", mode: :required
    schema.string "role_name", mode: :required
    schema.integer "school_urn", mode: :nullable
    schema.integer "trust_uid", mode: :nullable
    schema.string "user_id", mode: :required
  end
end
