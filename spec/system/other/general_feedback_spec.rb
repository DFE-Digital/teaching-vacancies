require "rails_helper"

RSpec.describe "Giving general feedback for the service", :recaptcha do
  let(:comment) { "Keep going!" }
  let(:email) { "test@example.com" }
  let(:occupation) { "teacher" }
  let(:visit_purpose_comment) { "testing" }

  it "can submit general feedback from any page" do
    visit jobs_path
    click_on I18n.t("footer.provide_feedback")
    expect(page).to have_content(I18n.t("general_feedbacks.new.heading"))

    click_on I18n.t("buttons.submit_feedback")
    expect(page).to have_content("There is a problem")

    fill_in_general_feedback

    expect { click_on I18n.t("buttons.submit_feedback") }.to change {
      Feedback.where(comment: comment,
                     email: email,
                     occupation: occupation,
                     feedback_type: "general",
                     rating: "highly_satisfied",
                     recaptcha_score: nil,
                     user_participation_response: "interested",
                     visit_purpose: "other_purpose",
                     visit_purpose_comment: visit_purpose_comment,
                     origin_path: jobs_path).count
    }.by(1)

    expect(page).to have_content(I18n.t("general_feedbacks.create.success"))
  end

  context "when recaptcha V3 check fails" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
    end

    it "requests the user to pass a recaptcha V2 check" do
      visit new_feedback_path
      click_on I18n.t("buttons.submit_feedback")
      expect(page).to have_content("There is a problem")

      fill_in_general_feedback

      expect { click_on I18n.t("buttons.submit_feedback") }.not_to change(Feedback, :count)
      expect(page).to have_content("There is a problem")
      expect(page).to have_content(I18n.t("recaptcha.error"))
      expect(page).to have_content(I18n.t("recaptcha.label"))
    end
  end

  def fill_in_general_feedback
    choose name: "general_feedback_form[report_a_problem]", option: "yes"
    choose I18n.t("helpers.label.general_feedback_form.visit_purpose_options.other_purpose")
    choose I18n.t("helpers.label.general_feedback_form.rating.highly_satisfied")

    fill_in "general_feedback_form[visit_purpose_comment]", with: visit_purpose_comment
    fill_in "general_feedback_form[comment]", with: comment

    choose name: "general_feedback_form[user_participation_response]", option: "interested"
    fill_in "email", with: email
    fill_in "occupation", with: occupation
  end
end
