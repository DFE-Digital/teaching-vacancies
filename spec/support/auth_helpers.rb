module AuthHelpers
  def stub_global_auth(return_value: true)
    allow_any_instance_of(ApplicationController)
      .to receive(:authenticate?)
      .and_return(return_value)
  end

  def stub_env_for_staging_auth(env_field_for_username: :http_user,
                                env_field_for_password: :http_pass,
                                env_value_for_username: "foo",
                                env_value_for_password: "bar")
    fake_env = double.as_null_object
    allow(Figaro).to receive(:env).and_return(fake_env)
    allow(fake_env).to receive(env_field_for_username.to_sym).and_return(env_value_for_username)
    allow(fake_env).to receive(env_field_for_password.to_sym).and_return(env_value_for_password)
  end

  def stub_hiring_staff_auth(urn: nil, uid: nil, la_code: "123", session_id: "session_id", email: nil)
    if urn.present?
      page.set_rack_session(urn: urn, uid: "", la_code: "")
    elsif uid.present?
      page.set_rack_session(urn: "", uid: uid, la_code: "")
    else
      page.set_rack_session(urn: "", uid: "", la_code: la_code)
    end
    page.set_rack_session(session_id: session_id)
    create(:user, oid: session_id, email: email, last_activity_at: Time.zone.now)
  end

  def stub_authentication_step(organisation_id: "939eac36-0777-48c2-9c2c-b87c948a9ee0",
                               school_urn: "110627", trust_uid: nil, la_code: "123",
                               email: "an-email@example.com")
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      provider: "dfe",
      uid: "161d1f6a-44f1-4a1a-940d-d1088c439da7",
      info: {
        email: email,
      },
      extra: {
        raw_info: {
          organisation: {
            id: organisation_id,
            urn: school_urn,
            uid: trust_uid,
            establishmentNumber: la_code,
          },
        },
      },
    )
  end

  def stub_authorisation_step(organisation_id: "939eac36-0777-48c2-9c2c-b87c948a9ee0",
                              fixture_file: "dfe_sign_in_authorisation_response.json")
    user_id = "161d1f6a-44f1-4a1a-940d-d1088c439da7"
    authorisation_response = File.read(Rails.root.join("spec", "fixtures", fixture_file))

    stub_request(
      :get,
      "https://test-url.local/services/test-service-id/organisations/#{organisation_id}/users/#{user_id}",
    ).to_return(body: authorisation_response, status: 200)
  end

  def stub_authorisation_step_with_not_found
    authorisation_response = File.read(
      Rails.root.join("spec/fixtures/dfe_sign_in_missing_authorisation_response.html"),
    )

    stub_request(
      :get,
      "https://test-url.local/services/test-service-id/organisations/939eac36-0777-48c2-9c2c-b87c948a9ee0/users/161d1f6a-44f1-4a1a-940d-d1088c439da7",
    ).to_return(body: authorisation_response, status: 404)
  end

  def stub_authorisation_step_with_external_error
    authorisation_response = File.read(
      Rails.root.join("spec/fixtures/dfe_sign_in_authorisation_external_error.json"),
    )

    stub_request(
      :get,
      "https://test-url.local/services/test-service-id/organisations/939eac36-0777-48c2-9c2c-b87c948a9ee0/users/161d1f6a-44f1-4a1a-940d-d1088c439da7",
    ).to_return(body: authorisation_response, status: 500)
  end

  def stub_sign_in_with_multiple_organisations(user_id: "161d1f6a-44f1-4a1a-940d-d1088c439da7",
                                               fixture_file: "dfe_sign_in_user_organisations_response.json")

    authorisation_response = File.read(Rails.root.join("spec", "fixtures", fixture_file))

    stub_request(
      :get,
      "https://test-url.local/users/#{user_id}/organisations",
    ).to_return(body: authorisation_response, status: 200)
  end

  def stub_sign_in_with_single_organisation(user_id: "some-user-id",
                                            fixture_file:
                                            "dfe_sign_in_user_user_organisations_response_with_single.json")
    authorisation_response = File.read(Rails.root.join("spec", "fixtures", fixture_file))

    stub_request(
      :get,
      "https://test-url.local/users/#{user_id}/organisations",
    ).to_return(body: authorisation_response, status: 200)
  end

  def sign_in_user
    within(".govuk-header__navigation.mobile-header-top-border") { click_on(I18n.t("nav.sign_in")) }
    click_on(I18n.t("sign_in.link"))
  end

  def sign_out_via_dsi
    # A request to logout is sent to DfE Sign-in system. On success DSI comes back at auth_dfe_signout_path
    expect(current_url).to include "#{ENV['DFE_SIGN_IN_ISSUER']}/session/end"
    # TODO: fix system specs to change default host to localhost:3000
    expect(current_url).to include CGI.escape(auth_dfe_signout_url(host: "127.0.0.1"))
    visit auth_dfe_signout_path
  end

  def stub_accepted_terms_and_conditions
    create(:user, oid: "161d1f6a-44f1-4a1a-940d-d1088c439da7", accepted_terms_at: 1.day.ago)
  end
end

RSpec.shared_examples "basic auth" do
  context "when the path is root" do
    let(:path) { "/" }

    it "returns 401 and asks for the basic auth credentials" do
      get path
      expect(response).to have_http_status(401)
    end

    context "when the correct basic auth credentials are given" do
      it "returns a 200" do
        create(:school)
        username = "username"
        password = "foobar"

        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: username,
                                  env_value_for_password: password)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)

        get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }

        expect(response).to have_http_status(200)
      end
    end

    context "when the incorrect basic auth credentials are given" do
      it "returns a 401" do
        create(:school)
        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: nil,
                                  env_value_for_password: nil)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials("wrong-user", "password")
        get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }
        expect(response).to have_http_status(401)
      end
    end
  end

  context "when the path is vacancy show" do
    let(:vacancy) { create(:vacancy) }

    it "returns 401 and asks for the basic auth credentials" do
      get jobs_path(vacancy)

      expect(response).to have_http_status(401)
    end

    context "when the correct basic auth credentials are given" do
      it "returns a 200" do
        create(:school)
        username = "username"
        password = "foobar"

        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: username,
                                  env_value_for_password: password)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)

        get jobs_path(vacancy), env: { 'HTTP_AUTHORIZATION': encoded_credentials }

        expect(response).to have_http_status(200)
      end
    end

    context "when the incorrect basic auth credentials are given" do
      it "returns a 401" do
        create(:school)
        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: nil,
                                  env_value_for_password: nil)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials("wrong-user", "password")
        get jobs_path(vacancy), env: { 'HTTP_AUTHORIZATION': encoded_credentials }
        expect(response).to have_http_status(401)
      end
    end
  end

  context "when the path is schools show" do
    it "returns 401 and asks for the basic auth credentials" do
      create(:school)

      get "/school"

      expect(response).to have_http_status(401)
    end

    context "when the correct basic auth credentials are given" do
      it "returns a 302 redirect to the OmniAuth provider" do
        create(:school)
        username = "username"
        password = "foobar"

        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: username,
                                  env_value_for_password: password)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)

        get "/school", env: { 'HTTP_AUTHORIZATION': encoded_credentials }

        expect(response).to have_http_status(302)
      end
    end

    context "when the incorrect basic auth credentials are given" do
      it "returns a 401" do
        create(:school)
        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: nil,
                                  env_value_for_password: nil)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials("wrong-user", "password")

        get "/school", env: { 'HTTP_AUTHORIZATION': encoded_credentials }

        expect(response).to have_http_status(401)
      end
    end
  end
end

RSpec.shared_examples "no basic auth" do
  context "when the path is root" do
    it "returns a 200" do
      stub_env_for_staging_auth(env_field_for_username: :http_user,
                                env_field_for_password: :http_pass,
                                env_value_for_username: nil,
                                env_value_for_password: nil)
      get "/"

      expect(response).to have_http_status(200)
    end
  end

  context "when the path is vacancy show" do
    it "returns a 200" do
      stub_env_for_staging_auth(env_field_for_username: :http_user,
                                env_field_for_password: :http_pass,
                                env_value_for_username: nil,
                                env_value_for_password: nil)
      vacancy = create(:vacancy)

      get jobs_path(vacancy)

      expect(response).to have_http_status(200)
    end
  end

  context "when the path is schools show" do
    it "returns a 302 redirect to the OmniAuth provider" do
      stub_env_for_staging_auth(env_field_for_username: :http_user,
                                env_field_for_password: :http_pass,
                                env_value_for_username: nil,
                                env_value_for_password: nil)
      school = create(:school)

      get organisation_path(school)

      expect(response).to have_http_status(302)
    end
  end
end
