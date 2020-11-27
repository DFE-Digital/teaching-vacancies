require "rails_helper"

RSpec.describe "Users can only be signed in to one type of account" do
  let!(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com") }
  let!(:publisher) { create(:publisher, dsi_data: dsi_data) }

  let(:school) { create(:school, urn: "110627") }
  let(:dsi_data) do
    { "school_urns" => [school.urn], "trust_uids" => [], "la_codes" => [] }
  end

  before(:each) do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
  end

  context "when a jobseeker is signed in" do
    before(:each) do
      login_as(jobseeker, scope: :jobseeker)
    end

    context "when email fallback is disabled" do
      let(:dsi_email_address) { Faker::Internet.email }

      before(:each) do
        allow(AuthenticationFallback).to receive(:enabled?) { false }
        OmniAuth.config.test_mode = true
        stub_accepted_terms_and_conditions
        stub_authentication_step email: dsi_email_address
        stub_authorisation_step
        stub_sign_in_with_multiple_organisations
      end

      after(:each) do
        OmniAuth.config.mock_auth[:default] = nil
        OmniAuth.config.mock_auth[:dfe] = nil
        OmniAuth.config.test_mode = false
      end

      it "signs out from the jobseeker account when signing in as a publisher using DSI" do
        visit jobseekers_account_path
        expect(page).to have_content(I18n.t("jobseekers.accounts.show.page_title"))

        visit root_path
        sign_in_publisher
        expect(page).to have_content("Jobs at #{school.name}")

        visit jobseekers_account_path
        expect(current_path).to eq(new_jobseeker_session_path)
      end
    end

    context "when email fallback is enabled" do
      let!(:login_key) do
        publisher.emergency_login_keys.create(
          not_valid_after: Time.current + Publishers::SignIn::Email::SessionsController::EMERGENCY_LOGIN_KEY_DURATION,
        )
      end

      before(:each) do
        allow(AuthenticationFallback).to receive(:enabled?) { true }
      end

      it "signs out from the jobseeker account when signing in as a publisher using DSI" do
        visit jobseekers_account_path
        expect(page).to have_content(I18n.t("jobseekers.accounts.show.page_title"))

        visit auth_email_choose_organisation_path(login_key: login_key.id)
        expect(page).to have_content("Jobs at #{school.name}")

        visit jobseekers_account_path
        expect(current_path).to eq(new_jobseeker_session_path)
      end
    end
  end

  context "when a publisher is signed in" do
    let!(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com", password: "passw0rd") }
    before(:each) do
      stub_publishers_auth(urn: "110627")
    end

    context "when email fallback is disabled" do
      before(:each) do
        allow(AuthenticationFallback).to receive(:enabled?) { false }
      end

      it "signs out from the publisher account when signing in as a jobseeker" do
        visit organisation_path
        expect(current_path).to eq(organisation_path)

        visit new_jobseeker_session_path
        fill_in "Email", with: "jobseeker@example.com"
        fill_in "Password", with: "passw0rd"
        click_button "Log in"

        expect(current_path).to eq(jobseekers_saved_jobs_path)

        visit organisation_path
        expect(current_path).to eq(new_identifications_path)
      end
    end

    context "when email fallback is enabled" do
      before(:each) do
        allow(AuthenticationFallback).to receive(:enabled?) { true }
      end

      it "signs out from the publisher account when signing in as a jobseeker" do
        visit organisation_path
        expect(current_path).to eq(organisation_path)

        visit new_jobseeker_session_path
        fill_in "Email", with: "jobseeker@example.com"
        fill_in "Password", with: "passw0rd"
        click_button "Log in"

        expect(current_path).to eq(jobseekers_saved_jobs_path)

        visit organisation_path
        expect(current_path).to eq(new_auth_email_path)
      end
    end
  end
end
