require 'rails_helper'

RSpec.shared_examples 'requires basic auth' do |path|
  let(:path) { path.present? ? path : '/' }

  it 'asks for the basic auth credentials' do
    fake_env = double.as_null_object
    allow(Figaro).to receive(:env).and_return(fake_env)
    allow(fake_env).to receive(:http_user?).and_return(true)
    allow(fake_env).to receive(:http_pass?).and_return(true)
    allow(fake_env).to receive(:http_user).and_return('username')
    allow(fake_env).to receive(:http_pass).and_return('password')

    get path
    expect(response).to have_http_status(401)
  end

  context 'when the correct basic auth credentials are given' do
    it 'returns a 200' do
      username = 'username'
      password = 'foobar'

      fake_env = double.as_null_object
      allow(Figaro).to receive(:env).and_return(fake_env)
      allow(fake_env).to receive(:http_user?).and_return(true)
      allow(fake_env).to receive(:http_pass?).and_return(true)
      allow(fake_env).to receive(:http_user).and_return(username)
      allow(fake_env).to receive(:http_pass).and_return(password)

      encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }
      expect(response).to have_http_status(200)
    end
  end

  context 'when the incorrect basic auth credentials are given' do
    it 'returns a 401' do
      fake_env = double.as_null_object
      allow(Figaro).to receive(:env).and_return(fake_env)
      allow(fake_env).to receive(:http_user?).and_return(true)
      allow(fake_env).to receive(:http_pass?).and_return(true)
      allow(fake_env).to receive(:http_user).and_return('correct-user')
      allow(fake_env).to receive(:http_pass).and_return('correct-password')

      encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials('wrong-user', 'password')
      get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }
      expect(response).to have_http_status(401)
    end
  end
end

RSpec.shared_examples 'does not require basic auth' do |path|
  let(:path) { path.present? ? path : '/' }

  it 'does not ask for the basic auth credentials' do
    fake_env = double.as_null_object
    allow(Figaro).to receive(:env).and_return(fake_env)
    allow(fake_env).to receive(:http_user?).and_return(false)
    allow(fake_env).to receive(:http_pass?).and_return(false)
    allow(fake_env).to receive(:http_user).and_return(nil)
    allow(fake_env).to receive(:http_pass).and_return(nil)

    get path
    expect(response).to have_http_status(200)
  end
end

RSpec.describe 'basic auth', type: :request do
  context 'when in development' do
    it_behaves_like 'does not require basic auth'
  end

  context 'when in test' do
    it_behaves_like 'does not require basic auth'
  end

  context 'when in staging' do
    before(:each) { stub_env_based_authentication }

    it_behaves_like 'requires basic auth'
  end

  context 'when in production' do
    before(:each) { stub_env_based_authentication }

    it_behaves_like 'requires basic auth'
  end

  def stub_env_based_authentication
    allow_any_instance_of(ApplicationController)
      .to receive(:authenticate?)
      .and_return(true)
  end
end
