require "rails_helper"

RSpec.describe "Jobseekers can transfer data from an old account" do
  include ActiveJob::TestHelper

  let(:jobseeker) { create(:jobseeker) }
  let(:old_jobseeker_account) { create(:jobseeker) }
  let!(:profile) { create(:jobseeker_profile, :completed, jobseeker: old_jobseeker_account) }
  let!(:old_submitted_application) { create(:job_application, :status_submitted, jobseeker: old_jobseeker_account) }
  let!(:old_draft_application) { create(:job_application, jobseeker: old_jobseeker_account) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let!(:saved_job) { create(:saved_job, vacancy:, jobseeker: old_jobseeker_account) }
  let!(:subscription) { create(:subscription, email: old_jobseeker_account.email) }

  before do
    ActionMailer::Base.deliveries.clear
    login_as(jobseeker, scope: :jobseeker)
    visit new_jobseekers_request_account_transfer_email_path
  end

  after { logout }

  context "when user requests transfer from an email which matches a jobseeker in our app" do
    it "allows user to request an account transfer" do
      visit jobseekers_profile_path

      expect_account_to_have_no_data

      visit new_jobseekers_request_account_transfer_email_path
      click_on "Save and continue"
      expect(page).to have_css("ul.govuk-list.govuk-error-summary__list")
      within "ul.govuk-list.govuk-error-summary__list" do
        expect(page).to have_link("Enter your email address", href: "#jobseekers-request-account-transfer-email-form-email-field-error")
      end

      fill_in "jobseekers_request_account_transfer_email_form[email]", with: "xxxxx"
      click_on "Save and continue"
      expect(page).to have_css("ul.govuk-list.govuk-error-summary__list")
      within "ul.govuk-list.govuk-error-summary__list" do
        expect(page).to have_link("Enter a valid email address in the correct format, like name@example.com", href: "#jobseekers-request-account-transfer-email-form-email-field-error")
      end

      fill_in "jobseekers_request_account_transfer_email_form[email]", with: old_jobseeker_account.email
      click_on "Save and continue"
      expect(delivered_emails.last.personalisation.fetch(:token)).to eq(old_jobseeker_account.reload.account_merge_confirmation_code)
      expect(page).not_to have_css("div.govuk-notification-banner__content p.govuk-notification-banner__heading", text: "Email resent")

      fill_in "jobseekers_account_transfer_form[account_merge_confirmation_code]", with: "somethingincorrect"
      click_on "Confirm account transfer"

      expect(page).to have_css("ul.govuk-list.govuk-error-summary__list")
      within "ul.govuk-list.govuk-error-summary__list" do
        expect(page).to have_link("Confirmation code does not match.", href: "#jobseekers-account-transfer-form-account-merge-confirmation-code-field-error")
      end

      old_jobseeker_account.update!(account_merge_confirmation_code_generated_at: Time.current - 2.minutes)
      find("details.govuk-details").click
      find("a.govuk-link", text: "send the code again").click

      expect(page).to have_css("div.govuk-notification-banner__content p.govuk-notification-banner__heading", text: "Email resent")

      fill_in "jobseekers_account_transfer_form[account_merge_confirmation_code]", with: old_jobseeker_account.reload.account_merge_confirmation_code
      click_on "Confirm account transfer"
      expect(page).to have_content I18n.t("jobseekers.account_transfers.create.success")

      expect_account_to_be_populated_with_old_account_data
    end
  end

  context "when user enters an email that does not match any jobseekers in our db" do
    it "allows user to request an account transfer but does not send an email" do
      visit new_jobseekers_request_account_transfer_email_path
      fill_in "jobseekers_request_account_transfer_email_form[email]", with: "nonexistant-user-email@gmail.com"
      click_on "Save and continue"
      expect(delivered_emails).to eq []
      expect(page).to have_content "Check your email"
    end
  end

  context "when the user tries to transfer data to their own account" do
    it "does not allow the account transfer" do
      visit jobseekers_profile_path

      expect_account_to_have_no_data

      visit new_jobseekers_request_account_transfer_email_path

      fill_in "jobseekers_request_account_transfer_email_form[email]", with: jobseeker.email
      click_on "Save and continue"

      within "ul.govuk-list.govuk-error-summary__list" do
        expect(page).to have_link("You entered the email of the account you are currently logged in to. The data in this account is already available to you and cannot be transferred.", href: "#jobseekers-request-account-transfer-email-form-email-field-error")
      end
    end
  end

  context "when the confirmation code has expired" do
    before do
      visit new_jobseekers_request_account_transfer_email_path
      fill_in "jobseekers_request_account_transfer_email_form[email]", with: old_jobseeker_account.email
      click_on "Save and continue"
      travel_to(Time.current + 61.minutes)
    end

    it "does not allow the account transfer" do
      fill_in "jobseekers-account-transfer-form-account-merge-confirmation-code-field", with: old_jobseeker_account.reload.account_merge_confirmation_code
      click_on "Confirm account transfer"

      expect(page).not_to have_content I18n.t("jobseekers.account_transfers.create.failure")
      expect(page).to have_css("ul.govuk-list.govuk-error-summary__list")
      within "ul.govuk-list.govuk-error-summary__list" do
        expect(page).to have_link("Confirmation code has expired. Please request a new code.", href: "#jobseekers-account-transfer-form-account-merge-confirmation-code-field-error")
      end
    end
  end

  context "when the user tries to request 2 or more confirmation code emails in quick succession" do
    it "only sends the first email" do
      visit new_jobseekers_request_account_transfer_email_path
      fill_in "jobseekers_request_account_transfer_email_form[email]", with: old_jobseeker_account.email
      click_on "Save and continue"

      expect(page).to have_content "Email sent to: #{old_jobseeker_account.email}"

      visit new_jobseekers_request_account_transfer_email_path
      fill_in "jobseekers_request_account_transfer_email_form[email]", with: old_jobseeker_account.email
      click_on "Save and continue"

      expect(page).to have_css("ul.govuk-list.govuk-error-summary__list")
      within "ul.govuk-list.govuk-error-summary__list" do
        expect(page).to have_link("Please wait 1 minute before requesting another code.", href: "#jobseekers-request-account-transfer-email-form-email-field-error")
      end
    end
  end

  def expect_account_to_have_no_data
    expect(page).not_to have_content profile.first_name
    expect(page).not_to have_content profile.last_name
    expect(page).not_to have_content profile.qualifications.first.name
    expect(page).not_to have_content profile.employments.first.organisation
    expect(page).not_to have_content profile.training_and_cpds.first.name

    visit jobseekers_job_applications_path

    expect(page).to have_content "Applications (0)"
    expect(page).to have_content "You have not applied for any jobs"

    visit jobseekers_saved_jobs_path

    expect(page).to have_content "You have no saved jobs"

    visit jobseekers_subscriptions_path

    expect(page).to have_content "You have no job alerts set up"
  end

  def expect_account_to_be_populated_with_old_account_data
    expect(page).to have_content profile.first_name
    expect(page).to have_content profile.last_name
    expect(page).to have_content profile.qualifications.first.name
    expect(page).to have_content profile.employments.first.organisation
    expect(page).to have_content profile.training_and_cpds.first.name

    visit jobseekers_job_applications_path

    expect(page).to have_content "Applications (2)"
    expect(page).to have_content old_submitted_application.vacancy.job_title
    expect(page).to have_content old_draft_application.vacancy.job_title

    visit jobseekers_saved_jobs_path

    expect(page).not_to have_content "You have no saved jobs"
    expect(page).to have_content saved_job.vacancy.job_title

    visit jobseekers_subscriptions_path

    expect(page).not_to have_content "You have no job alerts set up"
    expect(page).to have_content subscription.search_criteria.fetch("keyword", "")
  end
end
