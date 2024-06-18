require "rails_helper"

RSpec.describe "Users are redirected after sign in" do
  context "when the user is a jobseeker" do
    let(:jobseeker) { create(:jobseeker) }

    context "when a jobseeker is redirected to the sign in page" do
      let(:school) { create(:school) }
      let(:job) { create(:vacancy, organisations: [school]) }

      it "then the user is redirected back to the original page" do
        visit jobseekers_job_applications_path

        expect(page).to have_text(I18n.t("jobseekers.sessions.new.title"))
        sign_in_jobseeker

        expect(page).to have_current_path(jobseekers_job_applications_path, ignore_query: true)
      end

      it "then goes to a different page and signs in" do
        visit job_path(job)
        click_on I18n.t("jobseekers.job_applications.apply")

        expect(page).to have_text(I18n.t("jobseekers.sessions.new.title"))
        visit root_path

        visit new_jobseeker_session_path
        sign_in_jobseeker

        expect(page).to have_current_path(jobseekers_saved_jobs_path, ignore_query: true)
      end
    end

    context "when the user has one job application" do
      let(:school) { create(:school) }
      let(:job) { create(:vacancy, organisations: [school]) }

      before do
        create(:job_application, jobseeker: jobseeker, vacancy: job)
      end

      it "directs the user to 'My Applications'" do
        visit jobseekers_sign_in_path
        sign_in_jobseeker
        expect(page).to have_current_path(jobseekers_job_applications_path, ignore_query: true)
      end
    end

    context "when the user has no job applications" do
      it "directs the user to 'My saved jobs'" do
        visit jobseekers_sign_in_path
        sign_in_jobseeker
        expect(page).to have_current_path(jobseekers_saved_jobs_path, ignore_query: true)
      end
    end
  end

  context "when the user is a publisher" do
    let!(:organisation) { create(:school) }
    let(:publisher) { create(:publisher) }
    let(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation]) }

    before { allow(AuthenticationFallback).to receive(:enabled?).and_return(false) }

    around do |example|
      previous_default_mock_auth = OmniAuth.config.mock_auth[:default]
      previous_dfe_mock_auth = OmniAuth.config.mock_auth[:dfe]
      previous_test_mode_value = OmniAuth.config.test_mode

      stub_accepted_terms_and_conditions
      OmniAuth.config.test_mode = true
      stub_publisher_authentication_step(organisation_id: organisation.id, school_urn: organisation.urn)
      stub_publisher_authorisation_step(organisation_id: organisation.id)

      example.run

      OmniAuth.config.mock_auth[:default] = previous_default_mock_auth
      OmniAuth.config.mock_auth[:dfe] = previous_dfe_mock_auth
      OmniAuth.config.test_mode = previous_test_mode_value
    end

    context "when a publisher is redirected to the sign in page" do
      it "then the user is redirected back to the original page" do
        visit organisation_job_path(vacancy)
        expect(page).to have_text(I18n.t("publishers.sessions.new.sign_in.title"))

        sign_in_publisher

        expect(page).to have_current_path(organisation_job_path(vacancy), ignore_query: true)
      end

      it "then goes to a different page and signs in" do
        visit organisation_job_path(vacancy)
        visit root_path

        sign_in_publisher(navigate: true)

        expect(page).to have_current_path(publisher_root_path, ignore_query: true)
      end
    end

    context "when the organisation's profile is incomplete" do
      before { allow_any_instance_of(Organisation).to receive(:profile_complete?).and_return(false) }

      it "redirects to the interstitial profile completion reminder page" do
        sign_in_publisher(navigate: true)

        expect(page).to have_current_path(publishers_organisation_profile_incomplete_path(organisation), ignore_query: true)
        expect(page).to have_link(I18n.t("publishers.incomplete_profile.complete_link_text", organisation_type: :school), href: publishers_organisation_path(organisation))
      end
    end
  end
end
