require "rails_helper"

RSpec.describe "Feedback supportal section" do
  let!(:job_alert_feedback) do
    create(
      :feedback,
      feedback_type: :job_alert,
      comment: "Some job alert feedback text",
    )
  end

  let!(:other_feedback) do
    create(
      :feedback,
      feedback_type: :jobseeker_account,
      comment: "Some other feedback text",
    )
  end

  before do
    OmniAuth.config.test_mode = true

    stub_support_user_authentication_step
    stub_support_user_authorisation_step

    sign_in_support_user(navigate: true)
  end

  after do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  describe "General" do
    before do
      click_on "View user feedback"
    end

    it "shows only general feedback" do
      expect(page).to have_text("Some other feedback text")
      expect(page).not_to have_text("Some job alert feedback text")
    end

    it "allows categorisation" do
      within ".supportal-table-component--uncategorised" do
        expect(page).to have_text("Some other feedback text")
        select "Formatting", from: "feedbacks[][category]"
      end

      page.first("button", text: "Save changes").click

      expect(page).not_to have_css(".supportal-table-component--uncategorised")

      within ".supportal-table-component--formatting" do
        expect(page).to have_text("Some other feedback text")
      end
    end
  end

  describe "Job alerts" do
    before do
      click_on "View user feedback"
      click_on "Job alerts"
    end

    it "shows only job alert feedback" do
      expect(page).to have_text("Some job alert feedback text")
      expect(page).not_to have_text("Some other feedback text")
    end

    it "allows categorisation" do
      within ".supportal-table-component--uncategorised" do
        expect(page).to have_text("Some job alert feedback text")
        select "Insufficient job alerts", from: "feedbacks[][category]"
      end

      page.first("button", text: "Save changes").click

      expect(page).not_to have_css(".supportal-table-component--uncategorised")

      within ".supportal-table-component--insufficient_job_alerts" do
        expect(page).to have_text("Some job alert feedback text")
      end
    end
  end

  describe "Reporting periods" do
    let!(:old_job_alert_feedback) do
      create(
        :feedback,
        feedback_type: :job_alert,
        comment: "Some old job alert feedback text",
        created_at: "2022-03-16 10:00",
      )
    end

    let!(:older_job_alert_feedback) do
      create(
        :feedback,
        feedback_type: :job_alert,
        comment: "Some older job alert feedback text",
        created_at: "2022-01-05 10:00",
      )
    end

    let!(:old_other_feedback) do
      create(
        :feedback,
        feedback_type: :jobseeker_account,
        comment: "Some old other feedback text",
        created_at: "2022-03-16 10:00",
      )
    end

    let!(:older_other_feedback) do
      create(
        :feedback,
        feedback_type: :jobseeker_account,
        comment: "Some older other feedback text",
        created_at: "2022-01-05 10:00",
      )
    end

    it "allows selecting a reporting period which persists between tabs" do
      click_on "View user feedback"

      expect(page).to have_text(other_feedback.comment)
      expect(page).not_to have_text(old_other_feedback.comment)
      expect(page).not_to have_text(older_other_feedback.comment)

      select "2022-03-15 -> 2022-03-21", from: "reporting_period"
      click_on "Go"

      expect(page).not_to have_text(other_feedback.comment)
      expect(page).to have_text(old_other_feedback.comment)
      expect(page).not_to have_text(older_other_feedback.comment)

      click_on "Job alerts"

      expect(page).not_to have_text(job_alert_feedback.comment)
      expect(page).to have_text(old_job_alert_feedback.comment)
      expect(page).not_to have_text(older_job_alert_feedback.comment)

      select "2022-01-04 -> 2022-01-10", from: "reporting_period"
      click_on "Go"

      expect(page).not_to have_text(job_alert_feedback.comment)
      expect(page).not_to have_text(old_job_alert_feedback.comment)
      expect(page).to have_text(older_job_alert_feedback.comment)

      click_on "General"

      expect(page).not_to have_text(other_feedback.comment)
      expect(page).not_to have_text(old_other_feedback.comment)
      expect(page).to have_text(older_other_feedback.comment)
    end
  end
end
