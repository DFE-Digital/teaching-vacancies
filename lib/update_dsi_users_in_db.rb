require 'dfe_sign_in_api'

class UpdateDfeSignInUsers
  include DFESignIn

  def run!
    get_response_pages.each { |page| convert_to_users(page) }
  end

private

  def convert_to_users(dsi_users)
    dsi_users.each do |dsi_user|
      User.transaction do
        user = User.find_or_initialize_by(oid: dsi_user['userId'])
        user.email = dsi_user['email']
        user.given_name = dsi_user['givenName']
        user.family_name = dsi_user['familyName']
        # When a user is associated with multiple organisations,
        # DfE Sign In returns 1 user object per organisation.
        # Each of these user objects has the same userId.
        organisation = dsi_user['organisation']
        urn = organisation['URN']
        uid = organisation['UID']

        # All organisations have an EstablishmentNumber, but we only want this for identifying LAs by.
        # If a User has a dsi_data local_authority_code, they can sign in as that LA.
        # Assume that if and only if an organisation has no URN or UID, it is a Local Authority.
        la_code = urn.present? || uid.present? ? nil : organisation['EstablishmentNumber']

        school_urns = user.dsi_data&.[]('school_urns') || []
        trust_uids = user.dsi_data&.[]('trust_uids') || []

        user.dsi_data = {
          school_urns: (school_urns | [urn]).compact,
          trust_uids: (trust_uids | [uid]).compact,
          la_code: la_code,
        }
        user.save
      end
    end
  end

  def api_response(page: 1)
    DFESignIn::API.new.users(page: page)
  end
end
