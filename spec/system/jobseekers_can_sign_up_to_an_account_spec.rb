require "rails_helper"

RSpec.describe "Jobseekers can sign up to an account" do
  let(:jobseeker) { build(:jobseeker) }
  let(:created_jobseeker) { Jobseeker.first }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
  end

  describe "creating an account" do
    it "validates and submits the form, sends confirmation email and redirects to check your email page" do
      visit new_jobseeker_registration_path
      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect { sign_up_jobseeker }.to change { delivered_emails.count }.by(1)
      expect(current_path).to eql(jobseekers_check_your_email_path)
    end
  end

  describe "confirming email address" do
    before do
      visit new_jobseeker_registration_path
      sign_up_jobseeker
    end

    context "when the confirmation token is valid" do
      it "confirms email and redirects to saved jobs page" do
        confirm_email_address
        expect(current_path).to eql(jobseekers_saved_jobs_path)
        expect(page).to have_content(I18n.t("devise.confirmations.confirmed"))
      end
    end

    context "when the confirmation token is invalid" do
      before do
        travel_to 3.hours.from_now
      end

      it "does not confirm email and redirects to resend confirmation page" do
        confirm_email_address
        expect(current_path).to eql(jobseeker_confirmation_path)
        expect(page).to have_content(I18n.t("jobseekers.confirmations.new.title"))
      end

      context "when the confirmation email is resent" do
        it "resends confirmation email and redirects to check your email page" do
          expect { resend_confirmation_email }.to change { delivered_emails.count }.by(1)
          expect(current_path).to eql(jobseekers_check_your_email_path)
        end
      end
    end
  end
end
