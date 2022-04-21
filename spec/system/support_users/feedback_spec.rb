require "rails_helper"

RSpec.shared_examples "has a satisfaction rating table" do |data_testid, number_of_options|
  it "has the correct values" do
    expect(page).to have_selector("table[data-testid='#{data_testid}']")

    within(find("table[data-testid='#{data_testid}']")) do
      within(find('tr[data-testid="2022-03-22 -> 2022-03-28"]')) do
        (1..number_of_options).each do |n|
          expect(find("td:nth-child(#{n + 1})").text).to eq(n.to_s)
        end
      end
    end

    within(find("table[data-testid='#{data_testid}']")) do
      within(find('tr[data-testid="2022-02-22 -> 2022-02-28"]')) do
        (1..number_of_options).each do |n|
          expect(find("td:nth-child(#{n + 1})").text).to eq((n + number_of_options).to_s)
        end
      end
    end
  end
end

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
      feedback_type: :general,
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

  describe "Satisfaction ratings" do
    before do
      feedback_types = {
        unsubscribe: { unsubscribe_reason: %i[job_found circumstances_change not_relevant other_reason] },
        jobseeker_account: { rating: %i[highly_satisfied somewhat_satisfied neither somewhat_dissatisfied highly_dissatisfied] },
        vacancy_publisher: { rating: %i[highly_satisfied somewhat_satisfied neither somewhat_dissatisfied highly_dissatisfied] },
        job_alert: { relevant_to_user: %i[true false] },
        application: { rating: %i[highly_satisfied somewhat_satisfied neither somewhat_dissatisfied highly_dissatisfied] },
        close_account: { close_account_reason: %i[too_many_emails not_getting_any_value not_looking_for_job other_close_account_reason] },
      }

      feedback_types.each do |feedback_type, groupings|
        groupings.each do |grouping_key, feedback_responses|
          feedback_responses.each do |feedback_response|
            create_list(
              :feedback,
              feedback_responses.index(feedback_response) + 1,
              feedback_type: feedback_type,
              created_at: Time.new(2022, 3, 23, 10, 0),
              grouping_key => feedback_response,
            )

            create_list(
              :feedback,
              feedback_responses.index(feedback_response) + feedback_responses.count + 1,
              feedback_type: feedback_type,
              created_at: Time.new(2022, 2, 23, 10, 0),
              grouping_key => feedback_response,
            )
          end
        end
      end

      click_on "View user feedback"
      click_on "Satisfaction ratings"
    end

    context "'Job alert unsubscribe - reason given' table" do
      before { click_on "Job alert unsubscribe" }
      include_examples "has a satisfaction rating table", "job-alert-unsubscribe-reason", 4
    end

    context "'Satisfaction rating - jobseekers' table" do
      before { click_on "Jobseeker" }
      include_examples "has a satisfaction rating table", "satisfaction-rating-jobseekers", 5
    end

    context "'Satisfaction rating - hiring staff' table" do
      before { click_on "Hiring staff" }
      include_examples "has a satisfaction rating table", "satisfaction-rating-hiring-staff", 5
    end

    context "'Satisfaction rating - job alerts' table" do
      before { click_on "Job alert relevance" }
      include_examples "has a satisfaction rating table", "satisfaction-rating-job-alerts", 2
    end

    context "'Satisfaction rating - job application' table" do
      before { click_on "Job applications" }
      include_examples "has a satisfaction rating table", "satisfaction-rating-job-application", 5
    end

    context "'Close account reason' table" do
      before { click_on "Close account reason" }
      include_examples "has a satisfaction rating table", "close-account-reason", 4
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
        feedback_type: :general,
        comment: "Some old other feedback text",
        created_at: "2022-03-16 10:00",
      )
    end

    let!(:older_other_feedback) do
      create(
        :feedback,
        feedback_type: :general,
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
