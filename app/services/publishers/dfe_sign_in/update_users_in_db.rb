require "dfe_sign_in/api"

module Publishers::DfeSignIn
  class UpdateUsersInDb
    extend Publishers::DfeSignIn::Parsing

    class << self
      def convert_to_user(dsi_user)
        Publisher.transaction do
          user = Publisher.find_or_initialize_by(oid: dsi_user["userId"])
          user.update!(email: dsi_user["email"],
                       given_name: dsi_user["givenName"],
                       family_name: dsi_user["familyName"])

          # When a user is associated with multiple organisations,
          # DfE Sign In returns 1 user object per organisation.
          # Each of these user objects has the same userId.
          urn = dsi_user.dig("organisation", "URN")
          uid = dsi_user.dig("organisation", "UID")
          la_code = la_code(dsi_user)

          create_organisation_publisher(user, urn, uid, la_code)
        end
      end

      private

      def create_organisation_publisher(user, urn, uid, la_code)
        if urn
          organisation = Organisation.find_by(urn: urn)
          user.organisations << organisation if organisation
        elsif uid
          organisation = Organisation.find_by(uid: uid)
          user.organisations << organisation if organisation
        elsif la_code
          organisation = Organisation.find_by(local_authority_code: la_code)
          user.organisations << organisation if organisation
        end
      end
    end
  end
end
