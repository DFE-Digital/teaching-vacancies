require 'rails_helper'

RSpec.shared_examples 'basic auth is required' do |path, http_user, http_pass|
  let(:path) { path.present? ? path : '/' }

  it 'asks for the basic auth credentials' do
    get path
    expect(response).to have_http_status(401)
  end

  context 'when the correct basic auth credentials are given' do
    it 'returns a 200' do
      username = 'username'
      password = 'foobar'

      fake_env = double.as_null_object
      allow(Figaro).to receive(:env).and_return(fake_env)
      allow(fake_env).to receive(http_user.to_sym).and_return(username)
      allow(fake_env).to receive(http_pass.to_sym).and_return(password)

      encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }
      expect(response).to have_http_status(200)
    end
  end

  context 'when the incorrect basic auth credentials are given' do
    it 'returns a 401' do
      fake_env = double.as_null_object
      allow(Figaro).to receive(:env).and_return(fake_env)
      allow(fake_env).to receive(http_user.to_sym).and_return(nil)
      allow(fake_env).to receive(http_pass.to_sym).and_return(nil)

      encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials('wrong-user', 'password')
      get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }
      expect(response).to have_http_status(401)
    end
  end
end

RSpec.shared_examples 'does not require basic auth' do |path, http_user, http_pass|
  it 'does not ask for the basic auth credentials' do
    fake_env = double.as_null_object
    allow(Figaro).to receive(:env).and_return(fake_env)
    allow(fake_env).to receive(http_user.to_sym).and_return(nil)
    allow(fake_env).to receive(http_pass.to_sym).and_return(nil)

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
      stub_authenticate_hiring_staff(return_value: true)
    end

    it_behaves_like 'basic auth is required', '/', :http_user, :http_pass

    it 'posting to the create vacancy endpoint requires basic auth' do
      school = create(:school)

      path = school_vacancies_path(school.id)
      post path, params: { vacancy: { foo: :bar } }

      expect(response.status).to eq(401)
    end

    context 'and valid global basic auth has been provided' do
      let(:username) { 'username' }
      let(:password) { 'foobar' }
      let(:encoded_credentials) do
        ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      end

      before(:each) do
        fake_env = double.as_null_object
        allow(Figaro).to receive(:env).and_return(fake_env)
        allow(fake_env).to receive(:http_user).and_return(username)
        allow(fake_env).to receive(:http_pass).and_return(password)
      end

      it_behaves_like 'basic auth is required', '/schools', :hiring_staff_http_user, :hiring_staff_http_pass

      it 'posting to the create vacancy endpoint still requires the hiring staff basic auth' do
        school = create(:school)

        path = school_vacancies_path(school.id)
        post path, params: { vacancy: { foo: :bar } }, env: { 'HTTP_AUTHORIZATION': encoded_credentials }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'when in production' do
    before(:each) do
      stub_authenticate(return_value: true)
      stub_authenticate_hiring_staff(return_value: true)
    end

    it_behaves_like 'basic auth is required', '/', :http_user, :http_pass

    it 'posting to the create vacancy endpoint requires basic auth' do
      school = create(:school)

      path = school_vacancies_path(school.id)
      post path, params: { vacancy: { foo: :bar } }

      expect(response.status).to eq(401)
    end

    context 'and valid global basic auth has been provided' do
      let(:username) { 'username' }
      let(:password) { 'foobar' }
      let(:encoded_credentials) do
        ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      end

      before(:each) do
        fake_env = double.as_null_object
        allow(Figaro).to receive(:env).and_return(fake_env)
        allow(fake_env).to receive(:http_user).and_return(username)
        allow(fake_env).to receive(:http_pass).and_return(password)
      end

      it_behaves_like 'basic auth is required', '/schools', :hiring_staff_http_user, :hiring_staff_http_pass

      it 'posting to the create vacancy endpoint still requires the hiring staff basic auth' do
        school = create(:school)

        path = school_vacancies_path(school.id)
        post path, params: { vacancy: { foo: :bar } }, env: { 'HTTP_AUTHORIZATION': encoded_credentials }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  def stub_authenticate(return_value: true)
    allow_any_instance_of(ApplicationController)
      .to receive(:authenticate?)
      .and_return(return_value)
  end

  def stub_authenticate_hiring_staff(return_value: true)
    allow_any_instance_of(HiringStaff::BaseController)
      .to receive(:authenticate_hiring_staff?)
      .and_return(return_value)
  end
end
