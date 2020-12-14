require "rails_helper"

RSpec.describe "Jobseekers can submit account survey" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
  end

  context "when logged in" do
    before do
      login_as(jobseeker, scope: :jobseeker)
      visit jobseekers_saved_jobs_path
    end

    it "submits account survey" do
      click_on I18n.t("jobseekers.accounts.footer.survey_link")
      click_button I18n.t("buttons.submit")

      expect(page).to have_content("There is a problem")

      choose I18n.t("helpers.label.account_feedback.rating_options.somewhat_satisfied")
      fill_in "account_feedback[suggestions]", with: "amazing account features!"
      click_button I18n.t("buttons.submit")

      expect(current_path).to eq(jobseekers_saved_jobs_path)
      expect(page).to have_content(I18n.t("jobseekers.account_feedbacks.create.success"))
    end
  end

  context "when logged out" do
    before do
      visit new_jobseekers_account_feedback_path
    end

    it "redirects to the sign in page" do
      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end
end
