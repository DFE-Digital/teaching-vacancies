module Publishers::DfeSignIn::BigQueryExport
  class Approvers < Base
    TABLE_NAME = "dsi_approvers".freeze

    def call
      # See the note in `Users#call`: fetch the first page before deleting the table so a
      # DSI outage does not leave us with no data at all.
      pages = dsi_approvers

      delete_table(TABLE_NAME)
      pages.each { |page| insert_table_data(page) }
    rescue StandardError => e
      Rails.logger.warn("DSI API /approvers failed to respond with error: #{e.message}")
      raise ExportError, "#{e.message}, while exporting data from DSI /users endpoint into BigQ"
    end

    private

    def present_for_big_query(batch)
      batch.map do |user|
        {
          email: user["email"],
          family_name: user["familyName"],
          given_name: user["givenName"],
          la_code: la_code(user),
          trust_uid: user.dig("organisation", "uid"),
          role_id: user["roleId"],
          role_name: user["roleName"],
          school_urn: user.dig("organisation", "urn"),
          user_id: user["userId"],
        }
      end
    end

    def insert_table_data(batch)
      dataset.insert TABLE_NAME, present_for_big_query(batch), autocreate: true do |schema|
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
  end
end
