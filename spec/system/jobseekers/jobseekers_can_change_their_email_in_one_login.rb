require "rails_helper"

RSpec.describe "Jobseekers can schange their email in GovUK One Login" do
  context "when the jobseeker signs in after having changed their email address in GovUK One Login" do
    let(:original_email) { Faker::Internet.unique.email(domain: TEST_EMAIL_DOMAIN) }
    let(:updated_email) { Faker::Internet.unique.email(domain: TEST_EMAIL_DOMAIN) }
    let(:jobseeker) { create(:jobseeker, email: original_email) }

    before do
      sign_in_jobseeker_govuk_one_login(jobseeker, navigate: true, email: updated_email)
    end

    scenario "gets signed in with their updated email in teaching vacancies" do
      expect(page.current_path).to eq(jobseekers_job_applications_path)
      expect(page).to have_css("h1", text: I18n.t("jobseekers.job_applications.index.page_title"))
      expect(page).to have_link(text: I18n.t("nav.sign_out"))
      expect(jobseeker.reload.email).to eq(updated_email)
    end
  end
end
