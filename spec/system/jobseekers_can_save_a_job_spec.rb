require "rails_helper"

RSpec.describe "Jobseekers can save a job" do
  let(:school) { create(:school) }
  let(:vacancy) { create(:vacancy, :published) }
  let(:created_jobseeker) { Jobseeker.first }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    vacancy.organisation_vacancies.create(organisation: school)
  end

  context "when a jobseeker has an account" do
    let(:jobseeker) { create(:jobseeker) }

    context "when they are signed in to their account" do
      before do
        login_as(jobseeker, scope: :jobseeker)
      end

      context "when the job is not already saved" do
        it "saves the job" do
          save_job
          and_the_job_is_saved
        end
      end

      context "when the job is already saved" do
        before do
          SavedJob.find_or_create_by(jobseeker_id: jobseeker.id, vacancy_id: vacancy.id)
        end

        it "unsaves the job" do
          unsave_job
          and_the_job_is_unsaved
        end
      end
    end

    context "when they are not signed in to their account" do
      context "when the job is not already saved" do
        it "saves the job after signing in" do
          save_job
          expect(page).to have_content(I18n.t("messages.jobseekers.saved_jobs.unauthenticated"))
          sign_in_jobseeker
          and_the_job_is_saved
        end
      end

      context "when the job is already saved" do
        before do
          SavedJob.find_or_create_by(jobseeker_id: jobseeker.id, vacancy_id: vacancy.id)
        end

        it "does nothing after signing in" do
          save_job
          expect(page).to have_content(I18n.t("messages.jobseekers.saved_jobs.unauthenticated"))
          sign_in_jobseeker
          and_the_job_is_saved
        end
      end
    end
  end

  context "when a jobseeker does not have an account" do
    let(:jobseeker) { build(:jobseeker) }

    it "saves the job after signing up" do
      save_job
      expect(page).to have_content(I18n.t("messages.jobseekers.saved_jobs.unauthenticated"))
      click_on "Sign up"
      sign_up_jobseeker
      confirm_email_address
      and_the_job_is_saved
    end
  end

  def save_job
    visit job_path(vacancy)
    click_on I18n.t("jobseekers.saved_jobs.save")
  end

  def unsave_job
    visit job_path(vacancy)
    click_on I18n.t("jobseekers.saved_jobs.saved")
  end

  def and_the_job_is_saved
    expect(current_path).to eql(job_path(vacancy))
    expect(page).to have_content("You have saved this job. View all your saved jobs on your account")
    expect(page).to have_content(I18n.t("jobseekers.saved_jobs.saved"))
    expect(created_jobseeker.saved_jobs.pluck(:vacancy_id)).to include(vacancy.id)
  end

  def and_the_job_is_unsaved
    expect(current_path).to eql(job_path(vacancy))
    expect(page).to have_content(I18n.t("jobseekers.saved_jobs.save"))
    expect(created_jobseeker.saved_jobs.pluck(:vacancy_id)).not_to include(vacancy.id)
  end
end
