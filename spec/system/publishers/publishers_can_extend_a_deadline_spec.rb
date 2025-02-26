require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "Publishers can extend a deadline" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:expires_at) { vacancy.expires_at + 2.months }
  let(:extension_reason) { Faker::Lorem.paragraph }
  let(:vacancy) { Vacancy.last }

  around do |example|
    # Travel to mid-day to avoid any timezone issues
    travel_to DateTime.new(2024, 10, 6, 12, 0, 0) do
      example.run
    end
  end

  before do
    create(:vacancy, vacancy_type, organisations: [organisation], created_at: Date.yesterday)
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_jobs_with_type_path(vacancy_type)
    click_on vacancy.job_title
    click_on extend_expires_at
  end

  after { logout }

  context "when the vacancy has not expired" do
    let(:vacancy_type) { :published }
    let(:extend_expires_at) { I18n.t("publishers.vacancies.show.heading_component.action.extend_closing_date") }

    it "can be extended" do
      choose I18n.t("publishers.vacancies.extend_deadline.show.extension_reason.other_extension_reason"), name: "publishers_job_listing_extend_deadline_form[extension_reason]"

      fill_in "publishers_job_listing_extend_deadline_form[expires_at(1i)]", with: expires_at.year
      fill_in "publishers_job_listing_extend_deadline_form[expires_at(2i)]", with: expires_at.month
      fill_in "publishers_job_listing_extend_deadline_form[expires_at(3i)]", with: expires_at.day
      choose "9am", name: "publishers_job_listing_extend_deadline_form[expiry_time]"

      fill_in "publishers_job_listing_extend_deadline_form[other_extension_reason_details]", with: extension_reason

      click_on I18n.t("buttons.extend_closing_date")

      expect(current_path).to eq(organisation_jobs_with_type_path(:published))

      expect(vacancy.reload).to have_attributes(extension_reason: "other_extension_reason", other_extension_reason_details: extension_reason, expires_at: expires_at)
    end
  end

  context "when the vacancy has expired" do
    let(:vacancy_type) { :expired }
    let(:extend_expires_at) { I18n.t("publishers.vacancies.show.heading_component.action.relist") }
    let(:new_vacancy) { Vacancy.order(:created_at).last }

    before do
      fill_in "publishers_job_listing_relist_form[expires_at(1i)]", with: expires_at.year
      fill_in "publishers_job_listing_relist_form[expires_at(2i)]", with: expires_at.month
      fill_in "publishers_job_listing_relist_form[expires_at(3i)]", with: expires_at.day
      choose "9am", visible: false, name: "publishers_job_listing_relist_form[expiry_time]"

      choose I18n.t("publishers.vacancies.extend_deadline.show.extension_reason.didnt_find_right_candidate"), visible: false
    end

    it "returns an error without a publish date" do
      click_on I18n.t("buttons.relist_vacancy")

      expect(page).to have_content("There is a problem")
    end

    context "when re-listing for publication today" do
      before do
        choose I18n.t("helpers.label.publishers_job_listing_important_dates_form.publish_on_day_options.today", date: "6 October 2024"),
               visible: false, name: "publishers_job_listing_relist_form[publish_on_day]"

        click_on I18n.t("buttons.relist_vacancy")
      end

      it "creates a new vacancy" do
        expect(page).to have_content I18n.t("publishers.vacancies.relist.update.success", job_title: new_vacancy.job_title)
        expect(new_vacancy).not_to eq(vacancy)
      end

      it "publishes the relisted vacancy" do
        expect(current_path).to eq(organisation_job_summary_path(new_vacancy.id))
        expect(new_vacancy).to have_attributes(extension_reason: "didnt_find_right_candidate",
                                               publish_on: Date.today,
                                               expires_at: expires_at)
      end

      it "sends an event to analytics", :dfe_analytics do
        expect(:publisher_vacancy_relisted).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
          with_data: {
            relist_form: "{\"publish_on\":\"#{Date.today}\",\"expires_at\":\"#{expires_at.strftime('%FT%T.%L%:z')}\",\"extension_reason\":\"didnt_find_right_candidate\",\"other_extension_reason_details\":\"\"}",
          },
        )
      end

      context "when looking at tabs" do
        before do
          click_on "Job listings"
        end

        it "shows the new vacancy" do
          expect(page).to have_content "Closing date:22 November 2024 at 9am"
        end

        it "keeps the closed vacancy closed" do
          click_on I18n.t("jobs.dashboard.expired.tab_heading")
          expect(page).to have_content "Listing ended:22 September 2024 at 9am"
        end
      end
    end

    it "can be re-listed for publishing tomorrow" do
      choose I18n.t("helpers.label.publishers_job_listing_important_dates_form.publish_on_day_options.tomorrow", date: "7 October 2024"),
             name: "publishers_job_listing_relist_form[publish_on_day]"

      click_on I18n.t("buttons.relist_vacancy")

      expect(new_vacancy).to have_attributes(extension_reason: "didnt_find_right_candidate",
                                             publish_on: Date.tomorrow,
                                             expires_at: expires_at)
    end

    context "when choosing another publish date" do
      let(:publish_date) { 1.week.from_now.to_date }

      it "can be re-listed for publishing on another date" do
        choose I18n.t("helpers.label.publishers_job_listing_important_dates_form.publish_on_day_options.another_day"),
               name: "publishers_job_listing_relist_form[publish_on_day]"

        fill_in "publishers_job_listing_relist_form[publish_on(1i)]", with: publish_date.year
        fill_in "publishers_job_listing_relist_form[publish_on(2i)]", with: publish_date.month
        fill_in "publishers_job_listing_relist_form[publish_on(3i)]", with: publish_date.day

        click_on I18n.t("buttons.relist_vacancy")

        expect(page).to have_content I18n.t("publishers.vacancies.relist.update.success", job_title: vacancy.job_title)

        expect(new_vacancy).to have_attributes(extension_reason: "didnt_find_right_candidate",
                                               publish_on: publish_date,
                                               expires_at: expires_at)
      end
    end
  end
end
