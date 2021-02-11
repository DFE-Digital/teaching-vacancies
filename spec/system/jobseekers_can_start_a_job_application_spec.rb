require "rails_helper"

RSpec.describe "Jobseekers can start a job application" do
  let(:jobseeker) { build_stubbed(:jobseeker) }
  let(:vacancy) { create(:vacancy) }
  let(:school) { create(:school) }
  let(:created_job_application) { JobApplication.first }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(jobseeker_applications_enabled?)
    vacancy.organisation_vacancies.create(organisation: school)
  end

  context "when JobseekerApplicationsFeature is enabled" do
    let(:jobseeker_applications_enabled?) { true }

    context "when the jobseeker has an account" do
      let!(:jobseeker) { create(:jobseeker) }

      context "when the jobseeker is signed in" do
        before do
          login_as(jobseeker, scope: :jobseeker)
        end

        it "starts a job application" do
          apply_on_vacancy
          and_it_starts_a_job_application
        end
      end

      context "when the jobseeker is not signed in" do
        it "starts a job application after signing in" do
          apply_on_vacancy
          sign_in_jobseeker
          and_it_starts_a_job_application
        end
      end
    end

    context "when the jobseeker does not have an account" do
      it "starts a job application after signing up" do
        apply_on_vacancy
        click_on I18n.t("jobseekers.sessions.new.no_account.link")
        sign_up_jobseeker
        visit first_link_from_last_mail
        and_it_starts_a_job_application
      end
    end

    context "when JobseekerApplicationsFeature is disabled" do
      let(:jobseeker_applications_enabled?) { false }

      it "returns not found" do
        visit new_jobseekers_job_application_path(vacancy.id)
        expect(page.status_code).to eq(404)
      end
    end
  end

  def apply_on_vacancy
    visit job_path(vacancy)
    click_on I18n.t("jobseekers.job_applications.apply")
  end

  def start_application
    click_on I18n.t("buttons.start_application")
  end

  def and_it_starts_a_job_application
    expect { start_application }.to change { JobApplication.count }.by(1)
    expect(current_path).to eq(jobseekers_job_application_build_path(created_job_application, :personal_details))
  end
end
