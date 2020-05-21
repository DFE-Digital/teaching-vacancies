require 'dfe_sign_in_api'

class UpdateDfeSignInUsers
  include DFESignIn

  def run
    (1..number_of_pages).each do |page|
      response = api_response(page: page)

      if users_nil_or_empty?(response)
        Rollbar.log(:error,
          "DfE Sign In API responded with nil users during job #{self.class.name}")
        raise error_message_for(response)
      end

      convert_to_users(response['users'])
    end
  end

  private

  def convert_to_users(dsi_users)
    dsi_users.each do |dsi_user|
      User.transaction do
        user = User.find_or_initialize_by(oid: dsi_user['userId'])
        user.email = dsi_user['email']
        # When a user is associated with multiple organisations,
        # DfE Sign In returns 1 user object per organisation.
        # Each of these user objects has the same userId.
        organisation = dsi_user['organisation']
        user.dsi_data = {
          school_urns: Set.new(user.dsi_data['school_urns']).add(organisation['URN']),
          school_group_uids: Set.new(user.dsi_data['school_group_uids']).add(organisation['UID'])
        }
        user.save
      end
    end
  end

  def api_response(page: 1)
    DFESignIn::API.new.users(page: page)
  end
end
