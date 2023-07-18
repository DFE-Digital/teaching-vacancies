require "rails_helper"

RSpec.shared_examples "has a satisfaction rating table" do |data_testid, number_of_options|
  it "has the correct values" do
    expect(page).to have_selector("table[data-testid='#{data_testid}']")

    within(find("table[data-testid='#{data_testid}']")) do
      within(find("tr[data-testid='#{testid_for 1.month.ago}']")) do
        (1..number_of_options).each do |n|
          expect(find("td:nth-child(#{n + 1})").text).to eq(n.to_s)
        end
      end
    end

    within(find("table[data-testid='#{data_testid}']")) do
      within(find("tr[data-testid='#{testid_for 3.month.ago}']")) do
        (1..number_of_options).each do |n|
          expect(find("td:nth-child(#{n + 1})").text).to eq((n + number_of_options).to_s)
        end
      end
    end
  end

  def testid_for(time)
    [time.to_date.beginning_of_month, time.to_date.end_of_month].map(&:to_s).join(" -> ")
  end
end

RSpec.describe "Feedback supportal section" do
  let!(:job_alert_feedback) do
    create(
      :feedback,
      feedback_type: :job_alert,
      comment: "Some job alert feedback text",
      occupation: "Teacher",
    )
  end

  let!(:other_feedback) do
    create(
      :feedback,
      feedback_type: :general,
      comment: "Some other feedback text",
      occupation: "Student",
      rating: "highly_satisfied",
      email: "faketestingemail@someemail.com",
      user_participation_response: "interested",
      origin_path: "/jobs",
    )
  end
  let(:download_path) { Rails.root.join("tmp/test_download.csv").to_s }
  let(:csv) { CSV.parse(page.body) }

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

    it "allows user to download data" do
      click_link "Download general feedback report"
      expect(csv.first).to eq ["Created at", "Source", "Who", "Type", "Origin path", "Contact email", "Occupation", "CSAT", "Comment", "Category"]
      expect(csv.second).to eq [other_feedback.created_at.to_s, "identified", "jobseeker", other_feedback.feedback_type, other_feedback.origin_path, other_feedback.email, other_feedback.occupation, other_feedback.rating, other_feedback.comment, other_feedback.category]
    end

    it "shows feedback table" do
      within("table.govuk-table") do
        within("tbody.govuk-table__body") do
          within("tr:first-child") do
            timestamp = find("td:nth-child(1)").text
            source = find("td:nth-child(2)").text
            who = find("td:nth-child(3)").text
            feedback_type = find("td:nth-child(4)").text
            origin = find("td:nth-child(5)").text
            contact_email = find("td:nth-child(6)").text
            occupation = find("td:nth-child(7)").text
            csat = find("td:nth-child(8)").text
            comment = find("td:nth-child(9)").text

            expect(timestamp).to eq(other_feedback.created_at.to_s)
            expect(source).to eq("Identified")
            expect(who).to eq("Jobseeker")
            expect(occupation).to eq(other_feedback.occupation)
            expect(contact_email).to eq(other_feedback.email)
            expect(feedback_type).to eq(other_feedback.feedback_type)
            expect(origin).to eq(other_feedback.origin_path)
            expect(csat).to eq(I18n.t("helpers.label.general_feedback_form.rating.#{other_feedback.rating}"))
            expect(comment).to eq(other_feedback.comment)
          end
        end
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

    it "allows user to download data" do
      click_link "Download job alerts feedback report"
      expect(csv.first).to eq ["Timestamp", "Relevant?", "Comment", "Criteria", "Keyword", "Location", "Radius", "Working patterns", "Category"]
      expect(csv.second).to eq [job_alert_feedback.created_at.to_s, job_alert_feedback.relevant_to_user, job_alert_feedback.comment, "[]", nil, nil, nil, nil, job_alert_feedback.category]
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
              created_at: 1.months.ago,
              grouping_key => feedback_response,
            )

            create_list(
              :feedback,
              feedback_responses.index(feedback_response) + feedback_responses.count + 1,
              feedback_type: feedback_type,
              created_at: 3.month.ago,
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

      it "allows user to download data" do
        click_link "Download unsubscribe reports"

        expect(csv.first).to eq ["Reporting period", "Job found", "Circumstances change", "Not relevant", "Other reason"]
        expect(csv.second).to eq [testid_for(Date.today), "0", "0", "0", "0"]
        expect(csv.third).to eq [testid_for(Date.today - 1.month), "1", "2", "3", "4"]
      end
    end

    context "'Satisfaction rating - jobseekers' table" do
      before { click_on "Jobseeker" }
      include_examples "has a satisfaction rating table", "satisfaction-rating-jobseekers", 5

      it "allows user to download data" do
        click_link "Download jobseeker_account reports"

        expect(csv.first).to eq ["Reporting period", "Highly satisfied", "Somewhat satisfied", "Neither", "Somewhat dissatisfied", "Highly dissatisfied"]
        expect(csv.second).to eq [testid_for(Date.today), "0", "0", "0", "0", "0"]
        expect(csv.third).to eq [testid_for(Date.today - 1.month), "1", "2", "3", "4", "5"]
      end
    end

    context "'Satisfaction rating - hiring staff' table" do
      before { click_on "Hiring staff" }
      include_examples "has a satisfaction rating table", "satisfaction-rating-hiring-staff", 5

      it "allows user to download data" do
        click_link "Download vacancy_publisher reports"

        expect(csv.first).to eq ["Reporting period", "Highly satisfied", "Somewhat satisfied", "Neither", "Somewhat dissatisfied", "Highly dissatisfied"]
        expect(csv.second).to eq [testid_for(Date.today), "0", "0", "0", "0", "0"]
        expect(csv.third).to eq [testid_for(Date.today - 1.month), "1", "2", "3", "4", "5"]
      end
    end

    context "'Satisfaction rating - job alerts' table" do
      before { click_on "Job alert relevance" }
      include_examples "has a satisfaction rating table", "satisfaction-rating-job-alerts", 2

      it "allows user to download data" do
        click_link "Download job_alert reports"

        expect(csv.first).to eq ["Reporting period", "Relevant", "Not relevant"]
        expect(csv.second).to eq [testid_for(Date.today), "0", "0"]
        expect(csv.third).to eq [testid_for(Date.today - 1.month), "1", "2"]
      end
    end

    context "'Satisfaction rating - job application' table" do
      before { click_on "Job applications" }
      include_examples "has a satisfaction rating table", "satisfaction-rating-job-application", 5

      it "allows user to download data" do
        click_link "Download application reports"

        expect(csv.first).to eq ["Reporting period", "Highly satisfied", "Somewhat satisfied", "Neither", "Somewhat dissatisfied", "Highly dissatisfied"]
        expect(csv.second).to eq [testid_for(Date.today), "0", "0", "0", "0", "0"]
        expect(csv.third).to eq [testid_for(Date.today - 1.month), "1", "2", "3", "4", "5"]
      end
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

      fill_in "From", with: "2022-03-15"
      fill_in "To", with: "2022-03-21"
      click_on "Go"

      expect(page).to have_field("From", with: "2022-03-15")
      expect(page).to have_field("To", with: "2022-03-21")
      expect(page).not_to have_text(other_feedback.comment)
      expect(page).to have_text(old_other_feedback.comment)
      expect(page).not_to have_text(older_other_feedback.comment)

      click_on "Job alerts"

      expect(page).not_to have_text(job_alert_feedback.comment)
      expect(page).to have_text(old_job_alert_feedback.comment)
      expect(page).not_to have_text(older_job_alert_feedback.comment)

      fill_in "From", with: "2022-01-04"
      fill_in "To", with: "2022-01-10"
      click_on "Go"

      expect(page).to have_field("From", with: "2022-01-04")
      expect(page).to have_field("To", with: "2022-01-10")
      expect(page).not_to have_text(job_alert_feedback.comment)
      expect(page).not_to have_text(old_job_alert_feedback.comment)
      expect(page).to have_text(older_job_alert_feedback.comment)

      click_on "General"

      expect(page).to have_field("From", with: "2022-01-04")
      expect(page).to have_field("To", with: "2022-01-10")
      expect(page).not_to have_text(other_feedback.comment)
      expect(page).not_to have_text(old_other_feedback.comment)
      expect(page).to have_text(older_other_feedback.comment)
    end
  end
end
