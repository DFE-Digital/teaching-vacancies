require "rails_helper"

RSpec.describe "Jobseekers can save a job" do
  let(:school) { create(:school) }
  let(:vacancy) { create(:vacancy, :published, organisations: [school]) }
  let(:created_jobseeker) { Jobseeker.first }

  context "when a jobseeker has an account" do
    let(:jobseeker) { create(:jobseeker) }

    context "when they are signed in to their account" do
      before { login_as(jobseeker, scope: :jobseeker) }

      context "when the job is not already saved" do
        it "saves the job" do
          save_job
          and_the_job_is_saved
        end
      end

      context "when the job is already saved" do
        let!(:saved_job) { create(:saved_job, jobseeker:, vacancy:) }

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
          sign_in_jobseeker
          and_the_job_is_saved
        end
      end

      context "when the job is already saved" do
        let!(:saved_job) { create(:saved_job, jobseeker:, vacancy:) }

        it "does nothing after signing in" do
          save_job
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
      click_on I18n.t("jobseekers.sessions.new.no_account.link")
      sign_up_jobseeker
      visit first_link_from_last_mail
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
    expect(current_path).to eq(job_path(vacancy))
    expect(page).to have_content("You have saved this job. View all your saved jobs on your account")
    expect(page).to have_selector(:link_or_button, I18n.t("jobseekers.saved_jobs.saved"))
    expect(created_jobseeker.saved_jobs.pluck(:vacancy_id)).to include(vacancy.id)
  end

  def and_the_job_is_unsaved
    expect(current_path).to eq(job_path(vacancy))
    expect(page).to have_selector(:link_or_button, I18n.t("jobseekers.saved_jobs.save"))
    expect(created_jobseeker.saved_jobs.pluck(:vacancy_id)).not_to include(vacancy.id)
  end
end
