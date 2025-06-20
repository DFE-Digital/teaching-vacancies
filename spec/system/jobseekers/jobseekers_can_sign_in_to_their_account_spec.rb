require "rails_helper"

RSpec.describe "Jobseekers can sign in to their account" do
  context "when signing in an existing jobseeker already linked to a one login account" do
    let(:jobseeker) { create(:jobseeker) }

    scenario "signs in the jobseeker and send them back to their applications page" do
      sign_in_jobseeker_govuk_one_login(jobseeker, navigate: true)
      expect(page.current_path).to eq(jobseekers_job_applications_path)
      expect(page).to have_css("h1", text: I18n.t("jobseekers.job_applications.index.page_title"))
      expect(page).to have_link(text: I18n.t("nav.sign_out"))
    end
  end

  context "when signing in a user that has a closed account" do
    let(:jobseeker) { create(:jobseeker, account_closed_on: Date.yesterday) }

    it "allows them to sign in and reactivates their account" do
      sign_in_jobseeker_govuk_one_login(jobseeker, navigate: true)
      expect(page.current_path).to eq(jobseekers_job_applications_path)
      expect(page).to have_css("h1", text: I18n.t("jobseekers.job_applications.index.page_title"))
      expect(page).to have_link(text: I18n.t("nav.sign_out"))
      expect(jobseeker.reload.account_closed_on).to be_nil
    end
  end

  context "when signing in a jobseeker that has not yet linked their account to a one login account" do
    let(:jobseeker) { create(:jobseeker, govuk_one_login_id: nil) }

    scenario "signs in the jobseeker and send them back to the 'account found' landing page" do
      sign_in_jobseeker_govuk_one_login(jobseeker, navigate: true)
      expect(page.current_path).to eq(account_found_jobseekers_account_path)
      expect(page).to have_css("h1", text: I18n.t("jobseekers.accounts.account_found.page_title"))
      expect(page).to have_link(text: I18n.t("nav.sign_out"))
    end

    context "when the user sign-in following a vacancy quick apply link" do
      let(:jobseeker) { create(:jobseeker, govuk_one_login_id: nil) }
      let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }

      scenario "the user is sent to the quick application page" do
        visit new_jobseekers_job_job_application_path(vacancy.id)
        expect(current_path).to eq(new_jobseeker_session_path)

        sign_in_jobseeker_govuk_one_login(jobseeker)
        expect(current_path).to eq(new_jobseekers_job_job_application_path(vacancy.id))
        expect(page).to have_css("h2", text: I18n.t("jobseekers.job_applications.new.heading"))
        expect(page).to have_css("p.govuk-notification-banner__heading", text: "Account found")
        expect(page).to have_css("p.govuk-body", text: "We have found a teaching vacancies account using this email address.")
      end
    end
  end

  context "when signing in a jobseeker that hasn't an account in the service" do
    let(:jobseeker) { build_stubbed(:jobseeker, govuk_one_login_id: nil) }

    scenario "creates the account, signs in the jobseeker and sends them back to their new account landing page" do
      expect { sign_in_jobseeker_govuk_one_login(jobseeker, navigate: true) }.to change(Jobseeker, :count).by(1)
      expect(page.current_path).to eq(account_not_found_jobseekers_account_path)
      expect(page).to have_css("h1", text: I18n.t("jobseekers.accounts.account_not_found.page_title"))
      expect(page).to have_link(text: I18n.t("nav.sign_out"))
    end
  end

  context "when there is an error signing in" do
    let(:jobseeker) { create(:jobseeker) }

    scenario "does not sign in the jobseeker and displays an error message" do
      sign_in_jobseeker_govuk_one_login(jobseeker, navigate: true, error: true)
      expect(page.current_path).to eq(root_path)
      expect(page).to have_text(I18n.t("jobseekers.govuk_one_login_callbacks.openid_connect.error"))
      expect(page).to have_link(text: I18n.t("nav.sign_in"))
    end
  end

  context "when the user sign-in following a vacancy quick apply link" do
    let(:jobseeker) { create(:jobseeker) }
    let(:old_vacancy) { create(:vacancy, organisations: [build(:school)]) }
    let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }

    before { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: old_vacancy) }

    scenario "the user is sent to the quick application page" do
      visit new_jobseekers_job_job_application_path(vacancy.id)
      expect(current_path).to eq(new_jobseeker_session_path)

      sign_in_jobseeker_govuk_one_login(jobseeker)
      expect(current_path).to eq(new_jobseekers_job_job_application_path(vacancy.id))
      expect(page).to have_content(I18n.t("jobseekers.job_applications.new.description1"))
    end
  end
end
