require "rails_helper"

RSpec.describe "Giving general feedback for the service" do
  context "when all required fields are complete" do
    let(:comment) { "Keep going!" }

    scenario "can submit feedback" do
      visit new_feedback_path
      expect(page).to have_content(I18n.t("general_feedbacks.new.heading"))

      choose("general-feedback-form-visit-purpose-other-purpose-field")
      fill_in "general_feedback_form[visit_purpose_comment]", with: "testing"

      fill_in "general_feedback_form[comment]", with: comment

      choose("general-feedback-form-user-participation-response-interested-field")
      fill_in "email", with: "test@test.com"

      expect { click_button I18n.t("buttons.submit_feedback") }.to have_triggered_event(:feedback_provided)
        .with_data(comment: comment,
                   email: "test@test.com",
                   feedback_type: "general",
                   user_participation_response: "interested",
                   visit_purpose: "other_purpose",
                   visit_purpose_comment: "testing")

      expect(page).to have_content(I18n.t("general_feedbacks.create.success"))
    end
  end

  context "when all required fields are not complete" do
    scenario "can not submit feedback" do
      visit new_feedback_path
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
      expect(page).to have_current_path(invalid_recaptcha_path(form_name: "General feedback form"))
    end
  end
end
