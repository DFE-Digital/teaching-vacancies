module DfeSignIn
  # Maps a raw DSI user/approver hash to the row BigQuery expects. Pure functions: no HTTP,
  # no BigQuery, nothing to instantiate — just DSI-shaped hash in, BigQuery-shaped hash out.
  module UserRows
    class << self
      # The organisation in the user from the DSI response contains an establishment number,
      # which matches the LA code if the organisation is an LA. To be consistent with trusts
      # and schools, we only send the LA code to BigQuery if the organisation is of the right
      # type (i.e. it's an LA).
      #
      # There is a different schema for the /users and /users/approvers responses, so both
      # are checked here.
      def la_code(user)
        organisation = user["organisation"] || {}

        if organisation["Category"] == Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:local_authority]
          organisation["EstablishmentNumber"]
        elsif organisation.dig("category", "id") == Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:local_authority]
          organisation["establishmentNumber"]
        end
      end

      def for_users(dsi_user)
        {
          user_id: dsi_user["userId"],
          email: dsi_user["email"],
          given_name: dsi_user["givenName"],
          family_name: dsi_user["familyName"],
          role: dsi_user["roleName"],
          school_urn: dsi_user.dig("organisation", "URN"),
          trust_uid: dsi_user.dig("organisation", "UID"),
          la_code: la_code(dsi_user),
          approval_datetime: dsi_user["approvedAt"],
          update_datetime: dsi_user["updatedAt"],
        }
      end

      def for_approvers(dsi_approver)
        {
          user_id: dsi_approver["userId"],
          email: dsi_approver["email"],
          given_name: dsi_approver["givenName"],
          family_name: dsi_approver["familyName"],
          role_id: dsi_approver["roleId"],
          role_name: dsi_approver["roleName"],
          school_urn: dsi_approver.dig("organisation", "urn"),
          trust_uid: dsi_approver.dig("organisation", "uid"),
          la_code: la_code(dsi_approver),
        }
      end
    end
  end
end
