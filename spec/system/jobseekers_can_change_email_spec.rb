require "rails_helper"

RSpec.describe "Jobseekers can change email" do
  let(:jobseeker) { create(:jobseeker, email: "old@email.com", password: "password") }
  let(:created_jobseeker) { Jobseeker.first }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
    visit edit_jobseeker_registration_path
  end

  describe "updating email and confirming change" do
    it "validates and submits the form, sends emails, redirects to check your email page, confirms the change, updates the email and redirects to saved_jobs page" do
      update_jobseeker_email(jobseeker.email, jobseeker.password)
      expect(page).to have_content("There is a problem")

      expect { update_jobseeker_email("new@email.com", jobseeker.password) }.to change { delivered_emails.count }.by(2)
      expect(delivered_emails.first.subject).to eq(I18n.t("jobseeker_mailer.email_changed.subject"))
      expect(delivered_emails.first.to.first).to eq(jobseeker.email)
      expect(delivered_emails.second.subject).to eq(I18n.t("jobseeker_mailer.confirmation_instructions.reconfirmation.subject"))
      expect(delivered_emails.second.to.first).to eq("new@email.com")
      expect(current_path).to eq(jobseekers_check_your_email_path)

      visit first_link_from_last_mail

      expect(created_jobseeker.reload.email).to eq("new@email.com")
      expect(current_path).to eq(jobseekers_saved_jobs_path)
      expect(page).to have_content(I18n.t("devise.confirmations.confirmed"))
    end
  end

  def update_jobseeker_email(email, password)
    fill_in "jobseeker[current_password]", with: password
    fill_in "jobseeker[email]", with: email
    click_on I18n.t("buttons.continue")
  end
end
