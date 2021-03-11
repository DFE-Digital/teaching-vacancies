require "rails_helper"

RSpec.describe "Jobseekers can give account feedback" do
  let(:jobseeker) { create(:jobseeker) }

  context "when logged in" do
    let(:comment) { "amazing account features!" }

    before do
      login_as(jobseeker, scope: :jobseeker)
      visit jobseeker_root_path
    end

    it "submits account feedback and triggers a RequestEvent" do
      click_on I18n.t("jobseekers.account_survey_link_component.survey_link")

      choose I18n.t("helpers.label.jobseekers_account_feedback_form.rating_options.somewhat_satisfied")
      fill_in "jobseekers_account_feedback_form[comment]", with: comment

      expect { click_button I18n.t("buttons.submit") }.to have_triggered_event(:feedback_provided)
        .with_base_data(
          user_anonymised_jobseeker_id: StringAnonymiser.new(jobseeker.id).to_s,
        ).and_data(comment: comment, rating: "somewhat_satisfied", feedback_type: "jobseeker_account")

      expect(current_path).to eq(jobseeker_root_path)
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
