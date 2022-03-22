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
end
