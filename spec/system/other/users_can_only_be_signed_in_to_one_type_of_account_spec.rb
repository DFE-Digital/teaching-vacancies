require "rails_helper"

RSpec.describe "Users can only be signed in to one type of account" do
  let(:school) { create(:school, :with_image, urn: "110627") }

  let(:jobseeker) { create(:jobseeker) }
  let!(:publisher) { create(:publisher, organisations: [school]) }

  let(:authentication_fallback_enabled?) { false }

  before { allow(AuthenticationFallback).to receive(:enabled?).and_return(authentication_fallback_enabled?) }

  context "when a jobseeker is signed in" do
    before { login_as(jobseeker, scope: :jobseeker) }

    context "when email fallback is disabled" do
      let(:dsi_email_address) { Faker::Internet.email(domain: "example.com") }

      before do
        OmniAuth.config.test_mode = true
        stub_accepted_terms_and_conditions
        stub_publisher_authentication_step email: dsi_email_address
        stub_publisher_authorisation_step
        stub_sign_in_with_multiple_organisations
      end

      after do
        OmniAuth.config.mock_auth[:default] = nil
        OmniAuth.config.mock_auth[:dfe] = nil
        OmniAuth.config.test_mode = false
      end

      it "signs out from the jobseeker account when signing in as a publisher using DSI" do
        visit jobseekers_account_path
        expect(page).to have_content(I18n.t("jobseekers.accounts.show.page_title"))

        visit new_publisher_session_path
        sign_in_publisher
        expect(page).to have_current_path(publisher_root_path)

        visit jobseekers_account_path
        expect(current_path).to eq(new_jobseeker_session_path)
      end
    end

    context "when email fallback is enabled" do
      let(:authentication_fallback_enabled?) { true }
      let(:login_key) do
        EmergencyLoginKey.create(owner: publisher, not_valid_after: Time.current + Publishers::LoginKeysController::EMERGENCY_LOGIN_KEY_DURATION)
      end

      it "signs out from the jobseeker account when signing in as a publisher using DSI" do
        visit jobseekers_account_path
        expect(page).to have_content(I18n.t("jobseekers.accounts.show.page_title"))

        visit publishers_login_key_path(login_key)
        choose school.name
        click_button I18n.t("buttons.sign_in")
        expect(page).to have_current_path(publisher_root_path)

        visit jobseekers_account_path
        expect(current_path).to eq(new_jobseeker_session_path)
      end
    end
  end

  context "when a publisher is signed in" do
    before { login_publisher(publisher: publisher, organisation: school) }

    context "when email fallback is disabled" do
      it "signs out from the publisher account when signing in as a jobseeker" do
        visit organisation_jobs_with_type_path
        expect(current_path).to eq(organisation_jobs_with_type_path)

        visit new_jobseeker_session_path
        sign_in_jobseeker_govuk_one_login(jobseeker)

        expect(current_path).to eq(jobseekers_job_applications_path)

        visit organisation_jobs_with_type_path
        expect(current_path).to eq(new_publisher_session_path)
      end
    end

    context "when email fallback is enabled" do
      let(:authentication_fallback_enabled?) { true }

      it "signs out from the publisher account when signing in as a jobseeker" do
        visit organisation_jobs_with_type_path
        expect(current_path).to eq(organisation_jobs_with_type_path)

        visit new_jobseeker_session_path
        sign_in_jobseeker_govuk_one_login(jobseeker)

        expect(current_path).to eq(jobseekers_job_applications_path)

        visit organisation_jobs_with_type_path
        expect(current_path).to eq(new_publishers_login_key_path)
      end
    end
  end
end
