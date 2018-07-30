require 'rails_helper'

RSpec.describe 'DfE Sign-in' do
  before(:each) do
    ensure_omniauth_has_not_been_mocked_in_another_test
  end

  context 'when DfE Sign-in respond with an OIDC payload for authentication purposes' do
    context 'when that payload is unauthorised' do
      it 'redirects the user to the not authorised page' do
        params = {
          'code' => 'a-long-secret',
          'session_state' => '123.456'
        }

        get '/auth/dfe/callback', params: params

        expect(response.status).to eq(302)
        expect(response.body).to eq('Redirecting to /401...')
      end
    end
  end

  context 'when a user is linked back to our service with a redirect' do
    it 'routes the request back to the new sign-in page' do
      request = get '/auth/dfe/callback'
      expect(request).to redirect_to(new_dfe_path)
    end
  end

  def ensure_omniauth_has_not_been_mocked_in_another_test
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
  end
end
