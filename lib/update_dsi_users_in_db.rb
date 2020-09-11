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
        urn = dsi_user['organisation']['URN']
        uid = dsi_user['organisation']['UID']
        school_urns = user.dsi_data&.[]('school_urns') || []
        school_group_uids = user.dsi_data&.[]('school_group_uids') || []
        user.dsi_data = {
          school_urns: (school_urns | [urn]).compact,
          school_group_uids: (school_group_uids | [uid]).compact,
        }
        user.save
      end
    end
  end

  def api_response(page: 1)
    DFESignIn::API.new.users(page: page)
  end
end
