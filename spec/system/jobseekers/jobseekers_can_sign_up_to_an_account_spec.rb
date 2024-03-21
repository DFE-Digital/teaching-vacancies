require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "Jobseekers can sign up to an account" do
  let(:jobseeker) { build(:jobseeker) }
  let(:created_jobseeker) { Jobseeker.first }

  describe "creating an account" do
    it "validates and submits the form, triggers account created event, sends confirmation email and redirects to check your email page" do
      visit new_jobseeker_registration_path
      click_on I18n.t("buttons.create_account")
      expect(page).to have_content("There is a problem")

      within(".govuk-error-summary__list") do
        expect(page).to have_link("Enter your email address", href: "#jobseeker-email-field-error")
        expect(page).to have_link("Enter your password", href: "#jobseeker-password-field-error")
        expect(page).to have_link("Select what type of jobs you are looking for", href: "#jobseeker-account-type-field-error")
      end

      sign_up_jobseeker
      expect(current_path).to eq(jobseekers_check_your_email_path)
    end

    it "allows jobseekers to reset their password" do
      visit root_path
      find(:xpath, "//a[@href='/jobseekers/sign_up']").click
      fill_in "jobseeker[email]", with: jobseeker.email
      fill_in "jobseeker[password]", with: "Jobseeker1234"
      choose "Non-teaching support jobs"
      click_on I18n.t("buttons.create_account")

      expect(page).to have_content I18n.t("jobseekers.registrations.check_your_email.title")

      click_on I18n.t("jobseekers.registrations.check_your_email.resend_link")
      expect(page).to have_content I18n.t("jobseekers.registrations.check_your_email.resent_email_confirmation")

      confirm_email_address
      expect(current_path).to eq(confirmation_jobseekers_account_path)
    end
  end

  describe "confirming email address" do
    before do
      visit new_jobseeker_registration_path
      sign_up_jobseeker
    end

    context "when the confirmation token is valid" do
      it "confirms email, triggers email confirmed event and redirects to jobseeker account confirmation interstitial" do
        confirm_email_address
        expect(current_path).to eq(confirmation_jobseekers_account_path)
        expect(page).to have_content(I18n.t("jobseekers.accounts.confirmation.page_title"))
        expect(page).to have_link(I18n.t("jobseekers.accounts.confirmation.apply_for_jobs_link_text"), href: jobs_path)
        expect(page).to have_link(I18n.t("jobseekers.accounts.confirmation.create_profile.heading"), href: jobseekers_profile_path)
        expect(page).not_to have_content(I18n.t("devise.confirmations.confirmed"))
      end

      it "shows an error when trying to visit the confirmation link after a successfull confirmation" do
        confirm_email_address
        visit first_link_from_last_mail

        expect(page).to have_css("h1", text: I18n.t("jobseekers.confirmations.already_confirmed.title"))
        expect(page).to have_content(I18n.t("jobseekers.confirmations.already_confirmed.description"))
      end
    end

    context "when the user attempts to sign in without confirming their email" do
      it "does not allow user to sign in and shows the relevant error message" do
        within(".govuk-header__navigation") { click_on I18n.t("buttons.sign_in") }
        click_on I18n.t("buttons.sign_in_jobseeker")

        sign_in_jobseeker
        expect(page).to have_content "You need to confirm your email address to sign in. You should have received a link by email."
        expect(page).to have_content "If the link has expired, you can resend the email"

        click_link "resend the email"
        expect(page).to have_content "Email has been resent"

        confirm_email_address
        expect(current_path).to eq(confirmation_jobseekers_account_path)
      end

      context "when the user session does not contain the jobseeker information" do
        before do
          logout
        end

        it "asks the jobseeker to introduce their email address to receive the confirmation link" do
          within(".govuk-header__navigation") { click_on I18n.t("buttons.sign_in") }
          click_on I18n.t("buttons.sign_in_jobseeker")

          sign_in_jobseeker
          expect(page).to have_content "You need to confirm your email address to sign in. You should have received a link by email."
          expect(page).to have_content "If the link has expired, you can resend the email"

          click_link "resend the email"
          expect(page).to have_css("h1", text: "Resend confirmation")

          click_on "Resend email"
          expect(page).to have_css("h1", text: "Resend confirmation")
          expect(page).to have_css("h2", text: "There is a problem")
          expect(page).to have_content("Enter your email address")

          fill_in "Email address", with: jobseeker.email
          click_on "Resend email"
          expect(page).to have_css("h1", text: "Check your email")
          expect(page).to have_content "Email has been resent"

          confirm_email_address
          expect(current_path).to eq(confirmation_jobseekers_account_path)
        end
      end
    end

    context "when the existing confirmation period has expired" do
      before { travel_to 25.hours.from_now }

      context "when jobseeker tries to confirm their email" do
        before do
          confirm_email_address
        end

        it "informs user that the link has expired and allows them to resend email and confirm their email" do
          expect(page).to have_content("Link has expired")
          expect { click_on "Resend email" }.to change { delivered_emails.count }.by(1)
          expect(current_path).to eq(jobseekers_check_your_email_path)
          confirm_email_address
          expect(current_path).to eq(confirmation_jobseekers_account_path)
        end
      end

      context "when the confirmation email is resent" do
        it "resends confirmation email and redirects to check your email page" do
          expect { click_on "resend the email" }.to change { delivered_emails.count }.by(1)
          expect(page).to have_content "Email has been resent"
        end
      end
    end

    context "when the confirmation token does not exist" do
      it "takes the user to the 'not found' page" do
        visit jobseeker_confirmation_path(confirmation_token: "fooBar")
        expect(page).to have_content("Page not found")
      end
    end

    context "without confirmation token with existing confirmed users" do
      let!(:other_confirmed_jobseeker) { create(:jobseeker, confirmation_token: nil) }

      it "takes the user to the 'not found' page" do
        visit jobseeker_confirmation_path
        expect(page).to have_content("Page not found")
      end
    end
  end
end
