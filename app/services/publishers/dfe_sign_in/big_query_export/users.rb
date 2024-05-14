module Publishers::DfeSignIn::BigQueryExport
  class Users < Base
    TABLE_NAME = "dsi_users".freeze

    def call
      delete_table(TABLE_NAME)
      dsi_users.each { |page| insert_table_data(page) }
    rescue StandardError => e
      Rails.logger.warn("DSI API /users failed to respond with error: #{e.message}")
      raise "#{e.message}, while writing data from DSI /users endpoint. Flag this to Steven + Comms team"
    end

    private

    def present_for_big_query(batch)
      batch.map do |user|
        {
          approval_datetime: user["approvedAt"],
          email: user["email"],
          family_name: user["familyName"],
          given_name: user["givenName"],
          la_code: la_code(user),
          trust_uid: user.dig("organisation", "UID"),
          role: user["roleName"],
          school_urn: user.dig("organisation", "URN"),
          update_datetime: user["updatedAt"],
          user_id: user["userId"],
        }
      end
    end

    def insert_table_data(batch)
      dataset.insert TABLE_NAME, present_for_big_query(batch), autocreate: true do |schema|
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
  end
end
