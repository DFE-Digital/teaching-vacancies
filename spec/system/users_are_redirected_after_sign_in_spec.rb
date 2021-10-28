require "rails_helper"

RSpec.describe "Users are redirected after sign in" do
  context "when the user is a jobseeker" do
    let(:jobseeker) { create(:jobseeker) }

    scenario "when the jobseeker was redirected to the sign in page" do
      visit jobseekers_job_applications_path

      expect(page).to have_text(I18n.t("jobseekers.sessions.new.title"))
      sign_in_jobseeker

      expect(current_path).to eq(jobseekers_job_applications_path)
    end

    scenario "when the jobseeker goes to the sign in page" do
      visit jobseekers_sign_in_path
      sign_in_jobseeker

      expect(current_path).to eq(jobseeker_root_path)
    end
  end

  context "when the user is a publisher" do
    let!(:organisation) { create(:school) }
    let(:publisher) { create(:publisher) }
    let(:vacancy) { create(:vacancy, publisher: publisher) }

    before { allow(AuthenticationFallback).to receive(:enabled?) { false } }

    around do |example|
      previous_default_mock_auth = OmniAuth.config.mock_auth[:default]
      previous_dfe_mock_auth = OmniAuth.config.mock_auth[:dfe]
      previous_test_mode_value = OmniAuth.config.test_mode

      stub_accepted_terms_and_conditions
      OmniAuth.config.test_mode = true
      stub_authentication_step(organisation_id: organisation.id, school_urn: organisation.urn)
      stub_authorisation_step(organisation_id: organisation.id)

      example.run

      OmniAuth.config.mock_auth[:default] = previous_default_mock_auth
      OmniAuth.config.mock_auth[:dfe] = previous_dfe_mock_auth
      OmniAuth.config.test_mode = previous_test_mode_value
    end

    scenario "when the publisher was redirected to the sign in page" do
      visit organisation_job_path(vacancy)

      expect(page).to have_text(I18n.t("publishers.sessions.new.sign_in.title"))

      sign_in_publisher

      expect(current_path).to eq(organisation_job_path(vacancy))
    end

    scenario "when the publisher goes to the sign in page" do
      visit publishers_sign_in_path
      sign_in_publisher

      expect(current_path).to eq(organisation_path)
    end
  end
end
