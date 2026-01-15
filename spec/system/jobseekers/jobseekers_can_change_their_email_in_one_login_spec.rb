require "rails_helper"

RSpec.describe "Jobseekers can schange their email in GovUK One Login" do
  let(:original_email) { Faker::Internet.unique.email(domain: TEST_EMAIL_DOMAIN) }
  let(:updated_email) { Faker::Internet.unique.email(domain: TEST_EMAIL_DOMAIN) }
  let!(:one_login_jobseeker) { create(:jobseeker, email: original_email) }

  context "when the new email address does not match any TV account" do
    before { sign_in_jobseeker_govuk_one_login(one_login_jobseeker, navigate: true, email: updated_email) }
    after { logout }

    xscenario "gets signed in with their updated email in teaching vacancies" do
      expect(page).to have_current_path(jobseekers_job_applications_path, ignore_query: true)
      expect(page).to have_css("h1", text: I18n.t("jobseekers.job_applications.index.page_title"))
      expect(page).to have_link(text: I18n.t("nav.sign_out"))
      expect(one_login_jobseeker.reload.email).to eq(updated_email)
    end
  end

  context "when the new email address does match a pre-one login TV account" do
    let!(:pre_one_login_jobseeker) { create(:jobseeker, email: updated_email, govuk_one_login_id: nil) }
    let!(:pre_one_login_job_application) { create(:job_application, jobseeker: pre_one_login_jobseeker) }

    context "when the GovUK One Login user was a fresh account with no job applications" do
      before { sign_in_jobseeker_govuk_one_login(one_login_jobseeker, navigate: true, email: updated_email) }
      after { logout }

      xscenario "merges both accounts migrating the old account data into the new one" do
        expect(page).to have_current_path(jobseekers_job_applications_path, ignore_query: true)
        expect(page).to have_css("h1", text: I18n.t("jobseekers.job_applications.index.page_title"))

        # Has migrated the job application between accounts
        expect(page).to have_content(pre_one_login_job_application.vacancy.job_title)

        expect(page).to have_link(text: I18n.t("nav.sign_out"))
        expect(one_login_jobseeker.reload.email).to eq(updated_email)
      end
    end

    context "when the GovUK One Login user had already submitted an application" do
      let!(:job_application) { create(:job_application, jobseeker: one_login_jobseeker) }

      before { sign_in_jobseeker_govuk_one_login(one_login_jobseeker, navigate: true, email: updated_email) }
      after { logout }

      xscenario "gets signed in wile keeping their original email in teaching vacancies" do
        expect(page).to have_current_path(jobseekers_job_applications_path, ignore_query: true)
        expect(page).to have_css("h1", text: I18n.t("jobseekers.job_applications.index.page_title"))

        # Hasn't migrated the job application between accounts
        expect(page).to have_no_content(pre_one_login_job_application.vacancy.job_title)
        expect(page).to have_content(job_application.vacancy.job_title)

        expect(page).to have_link(text: I18n.t("nav.sign_out"))
        expect(one_login_jobseeker.reload.email).to eq(original_email)
      end
    end
  end
end
