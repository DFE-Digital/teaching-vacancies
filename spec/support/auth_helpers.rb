module AuthHelpers
  class MockPermissions < TeacherVacancyAuthorisation::Permissions
    def initialize(response)
      @response = response
    end

    def authorise(_identifier, school_urn = nil)
      @school_urn = school_urn
    end
  end

  def stub_global_auth(return_value: true)
    allow_any_instance_of(ApplicationController)
      .to receive(:authenticate?)
      .and_return(return_value)
  end

  def stub_env_for_staging_auth(env_field_for_username: :http_user,
                                env_field_for_password: :http_pass,
                                env_value_for_username: 'foo',
                                env_value_for_password: 'bar')
    fake_env = double.as_null_object
    allow(Figaro).to receive(:env).and_return(fake_env)
    allow(fake_env).to receive(env_field_for_username.to_sym).and_return(env_value_for_username)
    allow(fake_env).to receive(env_field_for_password.to_sym).and_return(env_value_for_password)
  end

  def stub_hiring_staff_auth(urn:, session_id: 'session_id')
    page.set_rack_session(urn: urn)
    page.set_rack_session(session_id: session_id)
    create(:user, oid: session_id)
  end
end

RSpec.shared_examples 'basic auth' do
  context 'when the path is root' do
    let(:path) { '/' }

    it 'returns 401 and asks for the basic auth credentials' do
      get path
      expect(response).to have_http_status(401)
    end

    context 'when the correct basic auth credentials are given' do
      it 'returns a 200' do
        create(:school)
        username = 'username'
        password = 'foobar'

        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
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
        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: nil,
                                  env_value_for_password: nil)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials('wrong-user', 'password')
        get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }
        expect(response).to have_http_status(401)
      end
    end
  end

  context 'when the path is vacancy show' do
    let(:vacancy) { create(:vacancy) }

    it 'returns 401 and asks for the basic auth credentials' do
      get jobs_path(vacancy)

      expect(response).to have_http_status(401)
    end

    context 'when the correct basic auth credentials are given' do
      it 'returns a 200' do
        create(:school)
        username = 'username'
        password = 'foobar'

        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: username,
                                  env_value_for_password: password)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)

        get jobs_path(vacancy), env: { 'HTTP_AUTHORIZATION': encoded_credentials }

        expect(response).to have_http_status(200)
      end
    end

    context 'when the incorrect basic auth credentials are given' do
      it 'returns a 401' do
        create(:school)
        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: nil,
                                  env_value_for_password: nil)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials('wrong-user', 'password')
        get jobs_path(vacancy), env: { 'HTTP_AUTHORIZATION': encoded_credentials }
        expect(response).to have_http_status(401)
      end
    end
  end

  context 'when the path is schools show' do
    it 'returns 401 and asks for the basic auth credentials' do
      create(:school)

      get '/school'

      expect(response).to have_http_status(401)
    end

    context 'when the correct basic auth credentials are given' do
      it 'returns a 302 redirect to the OmniAuth provider' do
        create(:school)
        username = 'username'
        password = 'foobar'

        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: username,
                                  env_value_for_password: password)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)

        get '/school', env: { 'HTTP_AUTHORIZATION': encoded_credentials }

        expect(response).to have_http_status(302)
      end
    end

    context 'when the incorrect basic auth credentials are given' do
      it 'returns a 401' do
        create(:school)
        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: nil,
                                  env_value_for_password: nil)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials('wrong-user', 'password')

        get '/school', env: { 'HTTP_AUTHORIZATION': encoded_credentials }

        expect(response).to have_http_status(401)
      end
    end
  end
end

RSpec.shared_examples 'no basic auth' do
  context 'when the path is root' do
    it 'returns a 200' do
      stub_env_for_staging_auth(env_field_for_username: :http_user,
                                env_field_for_password: :http_pass,
                                env_value_for_username: nil,
                                env_value_for_password: nil)
      get '/'

      expect(response).to have_http_status(200)
    end
  end

  context 'when the path is vacancy show' do
    it 'returns a 200' do
      stub_env_for_staging_auth(env_field_for_username: :http_user,
                                env_field_for_password: :http_pass,
                                env_value_for_username: nil,
                                env_value_for_password: nil)
      vacancy = create(:vacancy)

      get jobs_path(vacancy)

      expect(response).to have_http_status(200)
    end
  end

  context 'when the path is schools show' do
    it 'returns a 302 redirect to the OmniAuth provider' do
      stub_env_for_staging_auth(env_field_for_username: :http_user,
                                env_field_for_password: :http_pass,
                                env_value_for_username: nil,
                                env_value_for_password: nil)
      school = create(:school)

      get school_path(school)

      expect(response).to have_http_status(302)
    end
  end
end
