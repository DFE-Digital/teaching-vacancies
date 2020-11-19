require "rails_helper"

RSpec.describe "Giving general feedback for the service" do
  context "when all required fields are complete" do
    scenario "can submit feedback" do
      visit new_feedback_path
      expect(page).to have_content(I18n.t("feedback.heading"))

      choose("general-feedback-visit-purpose-find-teaching-job-field")
      fill_in "general_feedback[comment]", with: "Keep going!"

      choose("general-feedback-user-participation-response-interested-field")
      fill_in "email", with: "test@test.com"

      click_on I18n.t("buttons.submit_feedback")

      expect(page).to have_content(I18n.t("messages.feedback.submitted"))
    end
  end

  context "when all required fields are not complete" do
    scenario "can not submit feedback" do
      visit new_feedback_path
      expect(page).to have_content(I18n.t("feedback.heading"))
      click_on I18n.t("buttons.submit_feedback")
      expect(page).to have_content("There is a problem")
    end
  end

  context "when recaptcha score is invalid" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:recaptcha_reply).and_return({ "score" => 0.1 })
    end

    scenario "redirects to invalid_recaptcha path" do
      visit new_feedback_path
      click_on I18n.t("buttons.submit_feedback")
      expect(page).to have_current_path(invalid_recaptcha_path(form_name: "General feedback"))
    end
  end
end
