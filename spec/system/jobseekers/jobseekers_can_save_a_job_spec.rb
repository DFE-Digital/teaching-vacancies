require "rails_helper"

RSpec.describe "Jobseekers can save a job" do
  let(:school) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [school]) }
  let(:created_jobseeker) { Jobseeker.first }

  context "when a jobseeker has an account" do
    let(:jobseeker) { create(:jobseeker) }

    context "when they are signed in to their account" do
      before { login_as(jobseeker, scope: :jobseeker) }

      after { logout }

      context "when the job is not already saved" do
        it "saves the job" do
          save_job
          expect_the_job_to_be_saved
        end
      end

      context "when the job is already saved" do
        let!(:saved_job) { create(:saved_job, jobseeker: jobseeker, vacancy: vacancy) }

        it "unsaves the job" do
          unsave_job
          expect_the_job_to_no_longer_be_saved
        end
      end
    end

    context "when they are not signed in to their account" do
      context "when user has already logged in via one login previously" do
        context "when the job is not already saved" do
          xit "saves the job after signing in" do
            save_job
            sign_in_jobseeker_govuk_one_login(jobseeker)
            expect_the_job_to_be_saved
            expect(page).to have_no_content "New Teaching Vacancies account created"
          end
        end
      end

      context "when jobseeker has not logged in via one login previously" do
        context "when jobseeker has an existing TV account" do
          before do
            allow(jobseeker).to receive(:govuk_one_login_id).and_return(nil)
          end

          context "when the job is not already saved" do
            it "saves the job after signing in" do
              save_job
              sign_in_jobseeker_govuk_one_login(jobseeker)
              expect(page).to have_no_content "New Teaching Vacancies account created"
            end
          end
        end

        context "when jobseeker does not have an existing TV account" do
          let(:jobseeker) { build_stubbed(:jobseeker, govuk_one_login_id: nil) }

          context "when the job is not already saved" do
            xit "saves the job after signing in" do
              save_job
              sign_in_jobseeker_govuk_one_login(jobseeker)
              expect(page).to have_content "New Teaching Vacancies account created"
              expect(page).to have_content "You have saved this job in your new Teaching Vacancies account."
            end
          end
        end
      end

      context "when the job is already saved" do
        let!(:saved_job) { create(:saved_job, jobseeker: jobseeker, vacancy: vacancy) }

        xit "does nothing after signing in" do
          save_job
          sign_in_jobseeker_govuk_one_login(jobseeker)
          expect_the_job_to_be_saved
        end
      end
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

  def expect_the_job_to_be_saved
    expect(current_path).to eq(job_path(vacancy))
    expect(page).to have_content("You have saved this job. View all your saved jobs on your account")
    expect(page).to have_selector(:link_or_button, I18n.t("jobseekers.saved_jobs.saved"))
    expect(created_jobseeker.saved_jobs.pluck(:vacancy_id)).to include(vacancy.id)
  end

  def expect_the_job_to_no_longer_be_saved
    expect(current_path).to eq(job_path(vacancy))
    expect(page).to have_selector(:link_or_button, I18n.t("jobseekers.saved_jobs.save"))
    expect(created_jobseeker.saved_jobs.pluck(:vacancy_id)).not_to include(vacancy.id)
  end
end
