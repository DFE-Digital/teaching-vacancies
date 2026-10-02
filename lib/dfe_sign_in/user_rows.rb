module DfeSignIn
  # Wraps a raw DSI user/approver hash and maps it to the row BigQuery expects. No HTTP, no
  # BigQuery: just a DSI-shaped hash in, BigQuery-shaped hash out.
  class UserRows
    def initialize(dsi_user)
      @dsi_user = dsi_user
    end

    # The organisation in the user from the DSI response contains an establishment number,
    # which matches the LA code if the organisation is an LA. To be consistent with trusts
    # and schools, we only send the LA code to BigQuery if the organisation is of the right
    # type (i.e. it's an LA).
    #
    # There is a different schema for the /users and /users/approvers responses, so both
    # are checked here.
    def la_code
      if organisation["Category"] == Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:local_authority]
        organisation["EstablishmentNumber"]
      elsif organisation.dig("category", "id") == Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:local_authority]
        organisation["establishmentNumber"]
      end
    end

    def user_row
      {
        user_id: @dsi_user["userId"],
        email: @dsi_user["email"],
        given_name: @dsi_user["givenName"],
        family_name: @dsi_user["familyName"],
        role: @dsi_user["roleName"],
        school_urn: organisation["URN"],
        trust_uid: organisation["UID"],
        la_code: la_code,
        approval_datetime: @dsi_user["approvedAt"],
        update_datetime: @dsi_user["updatedAt"],
      }
    end

    def approver_row
      {
        user_id: @dsi_user["userId"],
        email: @dsi_user["email"],
        given_name: @dsi_user["givenName"],
        family_name: @dsi_user["familyName"],
        role_id: @dsi_user["roleId"],
        role_name: @dsi_user["roleName"],
        school_urn: organisation["urn"],
        trust_uid: organisation["uid"],
        la_code: la_code,
      }
    end

    private

    # Every DSI record is a user's membership of one organisation. A record without one can't
    # be tied to any publisher, so it raises rather than mapping to a row of nils.
    def organisation
      @dsi_user.fetch("organisation")
    end
  end
end
