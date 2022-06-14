require "rails_helper"
require "message_encryptor"

RSpec.shared_examples "a successful Support User sign in" do
  before do
    visit new_support_user_session_path
  end

  scenario "it signs in the user successfully" do
    expect { sign_in_support_user }
      .to have_triggered_event(:successful_support_user_sign_in_attempt)
      .with_base_data(user_anonymised_support_user_id: anonymised_form_of(user_oid))
      .with_data(sign_in_type: "dsi")

    within(".govuk-header__navigation") { expect(page).to have_selector(:link_or_button, I18n.t("nav.sign_out")) }
    within(".govuk-header__navigation") { expect(page).to have_selector(:link_or_button, I18n.t("nav.support_user_return_to_service")) }
  end
end

RSpec.shared_examples "a failed Support User sign in" do |options|
  scenario "it does not sign-in the user, and tells the user what to do" do
    visit new_support_user_session_path

    expect { sign_in_support_user }
      .to have_triggered_event(:failed_dsi_sign_in_attempt)
      .with_data(sign_in_type: "dsi", user_anonymised_id: anonymised_form_of(user_oid))

    expect(page).to have_content(/The email you're signed in with isn't authorised to list jobs for this school/i)
    expect(page).to have_content(options[:email])
    within(".govuk-header__navigation") { expect(page).not_to have_content(I18n.t("nav.school_page_link")) }
  end
end

RSpec.describe "Support users can sign in with DfE Sign In" do
  let(:user_oid) { "161d1f6a-44f1-4a1a-940d-d1088c439da7" }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  context "with valid credentials" do
    before do
      stub_support_user_authentication_step
      stub_support_user_authorisation_step
    end

    it_behaves_like "a successful Support User sign in"

    scenario "it redirects the sign in page to the support user dashboard" do
      sign_in_support_user(navigate: true)
      visit new_support_user_session_path

      expect(current_path).to eq(support_user_root_path)
      expect(page).to have_content(I18n.t("support_users.dashboard.heading"))
    end

    context "when navigating to publisher login page" do
      it "does not redirect to publisher dashboard" do
        sign_in_support_user(navigate: true)
        visit new_publisher_session_path

        expect(current_path).not_to eq(organisation_path)
      end
    end
  end

  context "with valid credentials but no authorisation" do
    before do
      create(:school, urn: "110627")
      stub_support_user_authentication_step(email: "another_email@example.com")
      stub_publisher_authorisation_step_with_not_found
    end

    it_behaves_like "a failed Support User sign in", email: "another_email@example.com"
  end

  context "when there is was an error with DfE Sign-in" do
    before do
      stub_support_user_authentication_step
      stub_publisher_authorisation_step_with_external_error
    end

    it "raises an error" do
      visit new_support_user_session_path

      expect { sign_in_support_user }.to raise_error(Authorisation::ExternalServerError)
    end
  end

  context "when there is an Omniauth error" do
    before do
      OmniAuth.config.mock_auth[:dfe] = :invalid_client
    end

    it "logs an error to Sentry and takes the user to the sign in page with an error message" do
      expect(Sentry).to receive(:capture_message)

      sign_in_support_user(navigate: true)

      expect(current_path).to eq(new_publisher_session_path)
      expect(page).to have_content(I18n.t("omniauth_callbacks.failure.message"))
    end
  end
end
