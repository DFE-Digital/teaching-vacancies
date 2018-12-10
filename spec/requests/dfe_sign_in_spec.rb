require 'rails_helper'

RSpec.describe 'DfE Sign-in', type: :request do
  context 'when DfE Sign-in respond with an OIDC payload for authentication purposes' do
    context 'when that openid connect payload is unauthorised' do
      it 'redirects the user to the not authorised page' do
        params = {
          'code': 'a-long-secret',
          'session_state': '123.456'
        }

        get auth_dfe_callback_path, params: params

        expect(response.status).to eq(401)
      end
    end
  end

  context 'when a user is linked back to our service without an openid connect payload' do
    it 'routes the request back to the new sign-in page' do
      get auth_dfe_callback_path

      expect(response).to redirect_to(new_dfe_path)
    end
  end
end
