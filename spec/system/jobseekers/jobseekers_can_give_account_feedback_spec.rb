require "rails_helper"

RSpec.describe "Jobseekers can give account feedback" do
  let(:jobseeker) { create(:jobseeker) }
  let(:comment) { "amazing account features!" }
  let(:occupation) { "Teaching assistant" }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_account_path
  end

  after { logout }

  describe "feedback" do
    before do
      click_on I18n.t("footer.provide_feedback")
    end

    it "submits account feedback" do
      choose name: "jobseekers_account_feedback_form[report_a_problem]", option: "yes"
      choose I18n.t("helpers.label.jobseekers_account_feedback_form.rating_options.somewhat_satisfied")
      choose name: "jobseekers_account_feedback_form[user_participation_response]", option: "interested"
      fill_in "jobseekers_account_feedback_form[comment]", with: comment
      fill_in "jobseekers_account_feedback_form[occupation]", with: occupation

      expect { click_button I18n.t("buttons.submit") }.to change {
        jobseeker.feedbacks.where(comment: comment,
                                  email: jobseeker.email,
                                  rating: "somewhat_satisfied",
                                  feedback_type: "jobseeker_account",
                                  user_participation_response: "interested",
                                  occupation: occupation,
                                  origin_path: jobseekers_account_path).count
      }.by(1)
      expect(current_path).to eq(jobseekers_account_path)
      expect(page).to have_content(I18n.t("jobseekers.account_feedbacks.create.success"))
    end
  end

  describe "email opt-out" do
    before do
      click_on I18n.t("jobseekers.accounts.show.email_preferences.link")
    end

    it "updates the opt out field and adds a feedback record", :js do
      choose I18n.t("helpers.label.jobseekers_email_preferences_form.email_opt_out_options.true")
      click_button I18n.t("buttons.save_changes")
      within ".govuk-list.govuk-error-summary__list" do
        expect(all("li a").map(&:text)).to eq(["Select your reason for opting out"])
      end
      choose "Other"
      fill_in "Tell us more (optional)", with: "Shant"
      expect { click_save_and_wait_for_banner }.to change {
        jobseeker.feedbacks.count
      }.by(1)
      expect(page).to have_content(I18n.t("jobseekers.email_preferences.update.success"))
    end
  end

  def click_save_and_wait_for_banner
    click_button I18n.t("buttons.save_changes")
    find(".govuk-notification-banner")
  end
end
