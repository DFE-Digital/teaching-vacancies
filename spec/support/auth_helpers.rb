module AuthHelpers
  def login_publisher(publisher:, organisation: nil, allow_reminders: false)
    organisation ||= publisher.organisations.first

    page.set_rack_session(visited_application_feature_reminder_page: true) unless allow_reminders
    page.set_rack_session(publisher_organisation_id: organisation.id)
    login_as(publisher, scope: :publisher)
  end

  def run_with_jobseeker(jobseeker)
    login_as(jobseeker, scope: :jobseeker)
    yield
    logout
  end

  def run_with_publisher(publisher)
    login_publisher(publisher: publisher)
    yield
    logout
  end

  def stub_publisher_authentication_step(organisation_id: "939eac36-0777-48c2-9c2c-b87c948a9ee0",
                                         school_urn: "110627", trust_uid: nil, la_code: nil,
                                         email: "an-email@example.com")
    category = "001" if school_urn.present?
    category = "010" if trust_uid.present?
    category = "002" if la_code.present?
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
            category: { id: category },
            establishmentNumber: la_code,
          },
        },
      },
    )
  end

  def stub_support_user_authentication_step(organisation_id: "939eac36-0777-48c2-9c2c-b87c948a9ee0", email: "an-email@example.com")
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
          },
        },
      },
    )
  end

  def stub_publisher_authorisation_step(organisation_id: "939eac36-0777-48c2-9c2c-b87c948a9ee0",
                                        fixture_file: "dfe_sign_in_publisher_authorisation_response.json")
    user_id = "161d1f6a-44f1-4a1a-940d-d1088c439da7"
    authorisation_response = File.read(Rails.root.join("spec", "fixtures", fixture_file))

    stub_request(
      :get,
      "https://test-url.local/services/test-service-id/organisations/#{organisation_id}/users/#{user_id}",
    ).to_return(body: authorisation_response, status: 200)
  end

  def stub_support_user_authorisation_step(organisation_id: "939eac36-0777-48c2-9c2c-b87c948a9ee0",
                                           fixture_file: "dfe_sign_in_support_user_authorisation_response.json")
    user_id = "161d1f6a-44f1-4a1a-940d-d1088c439da7"
    authorisation_response = File.read(Rails.root.join("spec", "fixtures", fixture_file))

    stub_request(
      :get,
      "https://test-url.local/services/test-service-id/organisations/#{organisation_id}/users/#{user_id}",
    ).to_return(body: authorisation_response, status: 200)
  end

  def stub_publisher_authorisation_step_with_not_found
    authorisation_response = File.read(
      Rails.root.join("spec/fixtures/dfe_sign_in_missing_authorisation_response.html"),
    )

    stub_request(
      :get,
      "https://test-url.local/services/test-service-id/organisations/939eac36-0777-48c2-9c2c-b87c948a9ee0/users/161d1f6a-44f1-4a1a-940d-d1088c439da7",
    ).to_return(body: authorisation_response, status: 404)
  end

  def stub_publisher_authorisation_step_with_external_error
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

  # Stubs the Jobseeker GovUK One Login authentication endpoints responses
  #
  # In order to stub a sucessfull authentication flow, it needs the 'govuk_one_login_nonce' from the user session to be
  # already set for the user session and provided here as "nonce" paramete (nonce coming from OneLogin needs to match
  # the one set in the users session).
  # That limits when this stub can be used, as it needs to be called after the user has navigated to the
  # 'new_jobseeker_session_path'.
  def stub_jobseeker_govuk_one_login_for(email:, one_login_id:, nonce:)
    stub_jobseeker_govuk_one_login_authorisation
    stub_jobseeker_govuk_one_login_tokens
    stub_jobseeker_govuk_one_login_jwt(nonce:, one_login_id:)
    stub_jobseeker_govuk_one_login_user_info(email:, one_login_id:)
  end

  def stub_jobseeker_govuk_one_login_authorisation
    redirection = "http://localhost:3000/jobseekers/auth/govuk_one_login/openid_connect?code=sSqw-cRMCT7f_-s18ITYmmkoZbvVxKVNJO9PxfBHPIU&state=de851994-a5bc-451e-a9c7-ce82d8f89848&controller=jobseekers/govuk_one_login_callbacks&action=openid_connect"
    stub_request(:get, Jobseekers::GovukOneLogin::ENDPOINTS[:login])
      .with(query: hash_including({}))
      .to_return(status: 301, headers: { "Location" => redirection })
  end

  def stub_jobseeker_govuk_one_login_tokens
    stub_request(:post, Jobseekers::GovukOneLogin::ENDPOINTS[:token])
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        body: {
          access_token: "eyJraWQiOiI3NmU3OWJmYzM1MDEzNzU5M2U1YmQ5OTJiMjAyZTI0OGZjOTdlN2EyMDk4OGE1ZDRmYmU5YTAyNzNlNTQ4NDRlIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJ1cm46ZmRjOmdvdi51azoyMDIyOmdwbnU4cmZzUFRmeFVIR1BaajlyakJySm9XaXVudURoYnZtMVVPNHhkbXMiLCJzY29wZSI6WyJlbWFpbCIsIm9wZW5pZCJdLCJpc3MiOiJodHRwczovL29pZGMuaW50ZWdyYXRpb24uYWNjb3VudC5nb3YudWsvIiwiZXhwIjoxNzI2ODc4OTEyLCJpYXQiOjE3MjY4Nzg3MzIsImNsaWVudF9pZCI6InlRZmJMNHBKZ0FhV2QzSURtVmROT09qbGQxWSIsImp0aSI6IjVlMmE5MzZhLTQ3ODgtNGU1OS05MWVhLTQwMzI1N2QxMDA5NSIsInNpZCI6IlRkcG5JZEZQYmNRTzFwUTNrUFdjZWRqekMxdyJ9.BHCJcegtRPzFxjRno2BBbd5FxbN5Iu1lAvu1XyCPe3sten6PKFKukfGsrd1GJUw3A0vRaT5CqnC0UjSoaFhLhc9hA5KhI5jmRtGJ4_o56ZIGbMybSQJP52oXXL6T49RtfA7OBaOkUsz6q-Ot-z-LEB0_Nc3Ur2EUlT1bOvd16lE7BjRK-f63aGMn3SwG9jC3WskpmmHkjHyUhnySTEo4J6hZes-6albJ1HTX3EnF1ezf1LRhuVoGNtVQpE4ndHEaNJAsA6YZ4VdnTxosx3HFZm1DnLMsYW5T5dflriXE9yXXrqyuCJJd5mczdUCUq-xIsEwGL42LNrzxuaCU_tNZYCpHA4U7Kv3omdUan1OooSjRUlbEpdcD3cud1xGJ72YF1F6vGV3cgIaqScnXmNboy5WmOILSHqsHLxgwDCPwBDqsFr9tKs7QvsYG6xMkvHh_gLpbzRT4aNsle05sOnXYg_d9Np8mfCbKaUXnPKZLKJVvE7e-3VKeCkXfy3sZx_n1kzx_ojq3bz4H2dzSxqcSOqjYm_Z6cQAVb6X-5cR-n6zsnzkcsjCRkjKTUZsaSfWdy3upHqIRj4U4cxl9_WM5gnhvkHlKMYRpefroVA1MnIoIOwuKfln6cM_cUDCmgqlWGV4dHlme4jvp1Zlk9SUTS3Zb1d7zIzr8_yIwtCQ68OQ",
          id_token: "eyJraWQiOiI3NmU3OWJmYzM1MDEzNzU5M2U1YmQ5OTJiMjAyZTI0OGZjOTdlN2EyMDk4OGE1ZDRmYmU5YTAyNzNlNTQ4NDRlIiwiYWxnIjoiUlMyNTYifQ.eyJhdF9oYXNoIjoiSHkzTVhVOVIxWHRHY2syVlZlcXlCdyIsInN1YiI6InVybjpmZGM6Z292LnVrOjIwMjI6Z3BudThyZnNQVGZ4VUhHUFpqOXJqQnJKb1dpdW51RGhidm0xVU80eGRtcyIsImF1ZCI6InlRZmJMNHBKZ0FhV2QzSURtVmROT09qbGQxWSIsImlzcyI6Imh0dHBzOi8vb2lkYy5pbnRlZ3JhdGlvbi5hY2NvdW50Lmdvdi51ay8iLCJ2b3QiOiJDbC5DbSIsImV4cCI6MTcyNjg3ODg1MiwiaWF0IjoxNzI2ODc4NzMyLCJub25jZSI6IjZwYURSTjBtaENVcTdMUW42QmVPbHc3cnUiLCJ2dG0iOiJodHRwczovL29pZGMuaW50ZWdyYXRpb24uYWNjb3VudC5nb3YudWsvdHJ1c3RtYXJrIiwic2lkIjoiVGRwbklkRlBiY1FPMXBRM2tQV2NlZGp6QzF3In0.arCFIeALQkz5q7Z2geLM7_qPuug8qrtiiaC9aBq52bZSFh9PMJGOgP2iCPC3Ty4XHKbS1Ei4Bq6ApbtK0TpjmnRJ63usbImIcYxNWNFiX_aGzAuLezXNVzGRhXzI42dbDaOGBgOY_J4Z1RPZn6N25M_8Wmpsi4X-7zSswccmzNd_LHm1DMmTWhnq5HlyEney1ZJIxCtI2Ckx0R9XutxSm0NOB39dH-MWvC3ZAhxMt6tn1LWgArZ7uisdnurgI50k3oX79LOH-WDuKqV-UJP7KEPn1A84ow3EVlAoGIr7ebTqrUXYtsYkiXYA47rMp-uahCkR_f9FCTEnvcJC2GYKP2yReiC8Qko0f1lip4m5IrwjxilxpXdewRzhunovegpazoWPqRNd22vclOQTf_roQMMskNUZHAf-QjEvKqan8t5DYfM3mT2w702XQzjUvezRnSM5ni1g5B3qMyKzuwPTSnmtot9qsqxVQIHS-VuKgMRCZBdK3bKYBJYger-bNQc7vACNBYsJssvbaOa2OKoQOTcxksjxlr2m4HRXvwxebwtVYzlae97XGtERSqP_byw8yKJuUeT2KUlfE8g4PWEOPV1oTW5TX7-M54iv-Tvau3OJ8MG-LkrA6OxbdoUb-PCJQJYHFILkYEbelCBosjOJGZh16OEix94DPKX0M2kOb5I",
          token_type: "Bearer",
          expires_in: 180,
        }.to_json,
      )
  end

  def stub_jobseeker_govuk_one_login_jwt(nonce: nil, one_login_id: nil)
    stub_request(:get, Jobseekers::GovukOneLogin::ENDPOINTS[:jwks])
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        body: {
          keys: [
            { kty: "EC", use: "sig", crv: "P-256", kid: "644af598b780f54106ca0f3c017341bc230c4f8373f35f32e18e3e40cc7acff6", x: "5URVCgH4HQgkg37kiipfOGjyVft0R5CdjFJahRoJjEw", y: "QzrvsnDy3oY1yuz55voaAq9B1M5tfhgW3FBjh_n_F0U", alg: "ES256" },
            { kty: "EC", use: "sig", crv: "P-256", kid: "e1f5699d068448882e7866b49d24431b2f21bf1a8f3c2b2dde8f4066f0506f1b", x: "BJnIZvnzJ9D_YRu5YL8a3CXjBaa5AxlX1xSeWDLAn9k", y: "x4FU3lRtkeDukSWVJmDuw2nHVFVIZ8_69n4bJ6ik4bQ", alg: "ES256" },
            { kty: "RSA", e: "AQAB", use: "sig", kid: "76e79bfc350137593e5bd992b202e248fc97e7a20988a5d4fbe9a0273e54844e", alg: "RS256", n: "lGac-hw2cW5_amtNiDI-Nq2dEXt1x0nwOEIEFd8NwtYz7ha1GzNwO2LyFEoOvqIAcG0NFCAxgjkKD5QwcsThGijvMOLG3dPRMjhyB2S4bCmlkwLpW8vY4sJjc4bItdfuBtUxDA0SWqepr5h95RAsg9UP1LToJecJJR_duMzN-Nutu9qwbpIJph8tFjOFp_T37bVFk4vYkWfX-d4-TOImOOD75G0kgYoAJLS2SRovQAkbJwC1bdn_N8yw7RL9WIqZCwzqMqANdo3dEgSb04XD_CUzL0Y2zU3onewH9PhaMfb11JhsuijH3zRA0dwignDHp7pBw8uMxYSqhoeVO6V0jz8vYo27LyySR1ZLMg13bPNrtMnEC-LlRtZpxkcDLm7bkO-mPjYLrhGpDy7fSdr-6b2rsHzE_YerkZA_RgX_Qv-dZueX5tq2VRZu66QJAgdprZrUx34QBitSAvHL4zcI_Qn2aNl93DR-bT8lrkwB6UBz7EghmQivrwK84BjPircDWdivT4GcEzRdP0ed6PmpAmerHaalyWpLUNoIgVXLa_Px07SweNzyb13QFbiEaJ8p1UFT05KzIRxO8p18g7gWpH8-6jfkZtTOtJJKseNRSyKHgUK5eO9kgvy9sRXmmflV6pl4AMOEwMf4gZpbKtnLh4NETdGg5oSXEuTiF2MjmXE" },
          ],
        }.to_json,
      )

    stubbed_id_token = "eyJraWQiOiI3NmU3OWJmYzM1MDEzNzU5M2U1YmQ5OTJiMjAyZTI0OGZjOTdlN2EyMDk4OGE1ZDRmYmU5YTAyNzNlNTQ4NDRlIiwiYWxnIjoiUlMyNTYifQ.eyJhdF9oYXNoIjoiSHkzTVhVOVIxWHRHY2syVlZlcXlCdyIsInN1YiI6InVybjpmZGM6Z292LnVrOjIwMjI6Z3BudThyZnNQVGZ4VUhHUFpqOXJqQnJKb1dpdW51RGhidm0xVU80eGRtcyIsImF1ZCI6InlRZmJMNHBKZ0FhV2QzSURtVmROT09qbGQxWSIsImlzcyI6Imh0dHBzOi8vb2lkYy5pbnRlZ3JhdGlvbi5hY2NvdW50Lmdvdi51ay8iLCJ2b3QiOiJDbC5DbSIsImV4cCI6MTcyNjg3ODg1MiwiaWF0IjoxNzI2ODc4NzMyLCJub25jZSI6IjZwYURSTjBtaENVcTdMUW42QmVPbHc3cnUiLCJ2dG0iOiJodHRwczovL29pZGMuaW50ZWdyYXRpb24uYWNjb3VudC5nb3YudWsvdHJ1c3RtYXJrIiwic2lkIjoiVGRwbklkRlBiY1FPMXBRM2tQV2NlZGp6QzF3In0.arCFIeALQkz5q7Z2geLM7_qPuug8qrtiiaC9aBq52bZSFh9PMJGOgP2iCPC3Ty4XHKbS1Ei4Bq6ApbtK0TpjmnRJ63usbImIcYxNWNFiX_aGzAuLezXNVzGRhXzI42dbDaOGBgOY_J4Z1RPZn6N25M_8Wmpsi4X-7zSswccmzNd_LHm1DMmTWhnq5HlyEney1ZJIxCtI2Ckx0R9XutxSm0NOB39dH-MWvC3ZAhxMt6tn1LWgArZ7uisdnurgI50k3oX79LOH-WDuKqV-UJP7KEPn1A84ow3EVlAoGIr7ebTqrUXYtsYkiXYA47rMp-uahCkR_f9FCTEnvcJC2GYKP2yReiC8Qko0f1lip4m5IrwjxilxpXdewRzhunovegpazoWPqRNd22vclOQTf_roQMMskNUZHAf-QjEvKqan8t5DYfM3mT2w702XQzjUvezRnSM5ni1g5B3qMyKzuwPTSnmtot9qsqxVQIHS-VuKgMRCZBdK3bKYBJYger-bNQc7vACNBYsJssvbaOa2OKoQOTcxksjxlr2m4HRXvwxebwtVYzlae97XGtERSqP_byw8yKJuUeT2KUlfE8g4PWEOPV1oTW5TX7-M54iv-Tvau3OJ8MG-LkrA6OxbdoUb-PCJQJYHFILkYEbelCBosjOJGZh16OEix94DPKX0M2kOb5I"
    allow(JWT).to receive(:decode).with(stubbed_id_token, anything, true, { verify_iat: true, algorithm: "RS256" }).and_return([{
      at_hash: "ZDevf74CkYWNPa8qmflQyA",
      sub: one_login_id || "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4",
      aud: Rails.application.config.govuk_one_login_client_id,
      iss: "#{Rails.application.config.govuk_one_login_base_url}/",
      vot: "Cl.Cm",
      exp: 1_704_894_526,
      iat: 1_704_894_406,
      nonce: nonce,
      vtm: "#{Rails.application.config.govuk_one_login_base_url}/trustmark",
      sid: "dX5xv0XgHh6yfD1xy-ss_1EDK0I",
    }.with_indifferent_access])
    allow(JWT).to receive(:decode).with(stubbed_id_token, nil, false).and_call_original
  end

  def stub_jobseeker_govuk_one_login_user_info(email: nil, one_login_id: nil)
    stub_request(:get, Jobseekers::GovukOneLogin::ENDPOINTS[:user_info])
    .with(query: hash_including({}))
    .to_return(
      status: 200,
      body: {
        sub: one_login_id || "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4",
        email: email || Faker::Internet.email(domain: TEST_EMAIL_DOMAIN),
        email_verified: true,
      }.to_json,
    )
  end

  # Signs in a jobseeker using the GovUK One Login authentication flow
  # The request/response from GovUK One Login are stubbed.
  # Options:
  # - navigate: If true, it will navigate to the 'new_jobseeker_session_path' before starting the authentication flow
  # - session: The session to be used for the authentication flow (if not provided, it will use the current session).
  #            This is only needed when "navigate" is false and the user navigated to the 'new_jobseeker_session_path'
  #            prior to calling this method
  # - error: If true, it will simulate an error in the GovUK One Login authentication flow. We simulate it by providing a
  #          wrong nonce in the callback response that doesn't match the one set in the user session.
  # - email: The email to be used in the GovUK One Login user info response. If not provided, it will usethe given
  #          jobseeker email)
  def sign_in_jobseeker_govuk_one_login(jobseeker, navigate: false, session: nil, error: false, email: nil)
    if navigate
      visit new_jobseeker_session_path
      expect(page).to have_link(I18n.t("buttons.one_login_sign_in"),
                                href: /^#{Jobseekers::GovukOneLogin::ENDPOINTS[:login]}/)
    end
    session ||= page.driver.request.session
    stub_jobseeker_govuk_one_login_for(email: email.presence || jobseeker.email,
                                       one_login_id: jobseeker.govuk_one_login_id,
                                       nonce: error ? "wrong-nonce-causes-error" : session[:govuk_one_login_nonce])
    one_login_url = find("a", text: I18n.t("buttons.one_login_sign_in"))[:href]

    # The rack_test driver doesn't support requests to external urls (the domain info is just ignored and all paths are
    # routed directly to the AUT)
    # https://stackoverflow.com/questions/49171142/rspec-capybara-redirect-to-external-page-sends-me-back-to-root-path
    # Simulates the external request directly
    Net::HTTP.get(URI(one_login_url))
    expect(a_request(:get, Jobseekers::GovukOneLogin::ENDPOINTS[:login]).with(query: hash_including({
      client_id: Rails.application.config.govuk_one_login_client_id,
      nonce: session[:govuk_one_login_nonce],
    }))).to have_been_made.once
    # Simulate the callback response from GovUK One Login
    visit auth_govuk_one_login_callback_path(code: "sSqw-cRMCT7f_-s18ITYmmkoZbvVxKVNJO9PxfBHPIU",
                                             state: session[:govuk_one_login_state])
  end

  def sign_in_publisher(navigate: false)
    visit new_publisher_session_path if navigate
    click_on I18n.t("buttons.continue_to_dsi")
  end

  def sign_in_support_user(navigate: false)
    visit new_support_user_session_path if navigate
    click_on I18n.t("support_users.sessions.new.button_text")
  end

  def stub_accepted_terms_and_conditions
    create(:publisher, oid: "161d1f6a-44f1-4a1a-940d-d1088c439da7", accepted_terms_at: 1.day.ago)
  end
end
