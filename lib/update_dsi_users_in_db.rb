require "dfe_sign_in_api"

class UpdateDsiUsersInDb
  include DFESignIn

  def run!
    response_pages.each { |page| convert_to_users(page) }
  end

  private

  def convert_to_users(dsi_users)
    dsi_users.each do |dsi_user|
      Publisher.transaction do
        user = Publisher.find_or_initialize_by(oid: dsi_user["userId"])
        user.email = dsi_user["email"]
        user.given_name = dsi_user["givenName"]
        user.family_name = dsi_user["familyName"]

        # When a user is associated with multiple organisations,
        # DfE Sign In returns 1 user object per organisation.
        # Each of these user objects has the same userId.
        urn = dsi_user.dig("organisation", "URN")
        uid = dsi_user.dig("organisation", "UID")
        la_code = la_code(dsi_user)

        user.save

        create_organisation_publisher(user, urn, uid, la_code)
      end
    end
  end

  def create_organisation_publisher(user, urn, uid, la_code)
    if urn
      organisation = Organisation.find_by(urn:)
      user.organisation_publishers.find_or_create_by(organisation_id: organisation.id) if organisation
    elsif uid
      organisation = Organisation.find_by(uid:)
      user.organisation_publishers.find_or_create_by(organisation_id: organisation.id) if organisation
    elsif la_code
      organisation = Organisation.find_by(local_authority_code: la_code)
      user.organisation_publishers.find_or_create_by(organisation_id: organisation.id) if organisation
    end
  end

  def api_response(page: 1)
    DFESignIn::API.new.users(page:)
  end
end
