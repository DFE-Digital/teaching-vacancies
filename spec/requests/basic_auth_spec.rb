require 'rails_helper'

RSpec.shared_examples 'basic auth is required' do |path, http_user, http_pass|
  let(:path) { path.present? ? path : '/' }

  it 'returns 401 and asks for the basic auth credentials' do
    get path
    expect(response).to have_http_status(401)
  end

  context 'when the correct basic auth credentials are given' do
    it 'returns a 200' do
      create(:school)
      username = 'username'
      password = 'foobar'

      stub_access_basic_auth_env(env_field_for_username: http_user,
                                 env_field_for_password: http_pass,
                                 env_value_for_username: username,
                                 env_value_for_password: password)

      encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }
      expect(response).to have_http_status(200)
    end
  end

  context 'when the incorrect basic auth credentials are given' do
    it 'returns a 401' do
      create(:school)
      stub_access_basic_auth_env(env_field_for_username: http_user,
                                 env_field_for_password: http_pass,
                                 env_value_for_username: nil,
                                 env_value_for_password: nil)

      encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials('wrong-user', 'password')
      get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }
      expect(response).to have_http_status(401)
    end
  end
end

RSpec.shared_examples 'does not require basic auth' do |path, http_user, http_pass|
  it 'returns a 200' do
    stub_access_basic_auth_env(env_field_for_username: http_user,
                               env_field_for_password: http_pass,
                               env_value_for_username: nil,
                               env_value_for_password: nil)

    get path
    expect(response).to have_http_status(200)
  end
end

RSpec.describe 'authentication', type: :request do
  context 'when in development' do
    it_behaves_like 'does not require basic auth', '/', :http_user, :http_pass
  end

  context 'when in test' do
    it_behaves_like 'does not require basic auth', '/', :http_user, :http_pass
  end

  context 'when in staging' do
    before(:each) do
      stub_authenticate(return_value: true)
    end

    it_behaves_like 'basic auth is required', '/', :http_user, :http_pass

    context 'and valid global basic auth has been provided' do
      let(:username) { 'username' }
      let(:password) { 'foobar' }
      let(:encoded_credentials) do
        ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      end

      before(:each) do
        stub_access_basic_auth_env(env_field_for_username: :http_user,
                                   env_field_for_password: :http_pass,
                                   env_value_for_username: username,
                                   env_value_for_password: password)
      end

      context 'and they try to visit publishing for a school' do
        it_behaves_like 'basic auth is required',
                        '/schools',
                        :hiring_staff_http_user,
                        :hiring_staff_http_pass

        it 'posting to the create vacancy endpoint still requires the hiring staff basic auth' do
          school = create(:school)
          path = school_vacancies_path(school.id)
          post path, params: { vacancy: { foo: :bar } }, env: { 'HTTP_AUTHORIZATION': encoded_credentials }

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  context 'when in production' do
    before(:each) do
      stub_authenticate(return_value: true)
    end

    it_behaves_like 'basic auth is required', '/', :http_user, :http_pass

    context 'and valid global basic auth has been provided' do
      let(:username) { 'username' }
      let(:password) { 'foobar' }
      let(:encoded_credentials) do
        ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      end

      before(:each) do
        stub_access_basic_auth_env(env_field_for_username: :http_user,
                                   env_field_for_password: :http_pass,
                                   env_value_for_username: username,
                                   env_value_for_password: password)
      end

      it_behaves_like 'basic auth is required', '/schools', :hiring_staff_http_user, :hiring_staff_http_pass
    end
  end
end
