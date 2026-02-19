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
          # :nocov:
          user.organisation_publishers.find_or_create_by(organisation_id: organisation.id) if organisation
          # :nocov:
        elsif uid
          organisation = Organisation.find_by(uid: uid)
          # :nocov:
          user.organisation_publishers.find_or_create_by(organisation_id: organisation.id) if organisation
          # :nocov:
        elsif la_code
          organisation = Organisation.find_by(local_authority_code: la_code)
          # :nocov:
          user.organisation_publishers.find_or_create_by(organisation_id: organisation.id) if organisation
          # :nocov:
        end
      end
    end
  end
end
