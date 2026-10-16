module Publishers::DfeSignIn
  module Parsing
    # The organisation in the user from the DSI response contains an establishment number,
    # which matches the LA code if the organisation is an LA. To be consistent with trusts
    # and schools, we only send the LA code to BigQuery if the organisation is of the right
    # type (i.e. it's an LA).
    #
    # There is a different schema for the /users and /users/approvers responses, so both
    # are checked here.
    #
    # Every DSI record is a user's membership of one organisation. A record without one can't
    # be tied to any publisher, so it raises rather than returning nil.
    def la_code(user)
      organisation = user.fetch("organisation")

      if organisation["Category"] == OrgIdMappings::CATEGORIES[:local_authority]
        organisation["EstablishmentNumber"]
      elsif organisation.dig("category", "id") == OrgIdMappings::CATEGORIES[:local_authority]
        organisation["establishmentNumber"]
      end
    end
  end
end
