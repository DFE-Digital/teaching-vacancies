# This is loaded correctly by Zeitwerk due to a custom inflection in config/initializers/inflections.rb
require "dfe_sign_in/api"
require "big_query/table"
require "big_query/table_sync"

class ExportDSIUsersToBigQueryJob < ApplicationJob
  include Publishers::DfeSignIn::BigQueryExport

  queue_as :low

  def perform
    return if DisableIntegrations.enabled?

    BigQuery::TableSync.call(
      table: BigQuery::Table.new("dsi_users", key: %i[user_id school_urn trust_uid la_code], schema: method(:define_schema)),
      rows: DfeSignIn::API.users.map { |user| big_query_row(user) },
    )
  end

  private

  def big_query_row(user)
    {
      approval_datetime: timestamp(user["approvedAt"]),
      email: user["email"],
      family_name: user["familyName"],
      given_name: user["givenName"],
      la_code: integer(la_code(user)),
      trust_uid: integer(user.dig("organisation", "UID")),
      role: user["roleName"],
      school_urn: integer(user.dig("organisation", "URN")),
      update_datetime: timestamp(user["updatedAt"]),
      user_id: user["userId"],
    }
  end

  def define_schema(schema)
    schema.timestamp "approval_datetime", mode: :nullable
    schema.string "email", mode: :nullable, policy_tags: [POLICY_TAG_MASKED]
    schema.string "family_name", mode: :nullable, policy_tags: [POLICY_TAG_MASKED]
    schema.string "given_name", mode: :nullable, policy_tags: [POLICY_TAG_MASKED]
    schema.integer "la_code", mode: :nullable
    schema.string "role", mode: :nullable
    schema.integer "school_urn", mode: :nullable
    schema.integer "trust_uid", mode: :nullable
    schema.timestamp "update_datetime", mode: :nullable
    schema.string "user_id", mode: :nullable
  end
end
