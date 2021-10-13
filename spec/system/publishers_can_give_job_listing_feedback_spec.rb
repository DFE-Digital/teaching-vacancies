require "rails_helper"

RSpec.describe "Publishers can give job listing feedback" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:comment) { "I love this service!" }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_job_summary_path(vacancy.id)
  end

  context "when the vacancy is not published" do
    let(:vacancy) { create(:vacancy, :draft, organisations: [organisation], publisher: publisher) }

    it "redirects to review page" do
      expect(current_path).to eq(organisation_job_review_path(vacancy.id))
    end
  end

  context "when the vacancy is published" do
    let(:vacancy) { create(:vacancy, :published, organisations: [organisation], publisher: publisher) }

    it "submits blank feedback, renders error and then submits feedback successfully" do
      click_on I18n.t("buttons.submit_feedback")

      expect(page).to have_content("There is a problem")

      choose name: "publishers_job_listing_feedback_form[report_a_problem]", option: "yes"
      choose I18n.t("helpers.label.publishers_job_listing_feedback_form.rating_options.somewhat_satisfied")
      choose name: "publishers_job_listing_feedback_form[user_participation_response]", option: "interested"
      fill_in "publishers_job_listing_feedback_form[comment]", with: comment

      expect { click_on I18n.t("buttons.submit_feedback") }.to change {
        publisher.feedbacks.where(comment: comment, email: publisher.email, feedback_type: "vacancy_publisher", user_participation_response: "interested", vacancy_id: vacancy.id).count
      }.by(1)

      expect(current_path).to eq(jobs_with_type_organisation_path(:published))

      expect(page).to have_content(I18n.t("messages.jobs.feedback.success"))
    end
  end
end
