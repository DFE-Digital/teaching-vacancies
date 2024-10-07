require "rails_helper"

RSpec.describe "Publishers can extend a deadline" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:expires_at) { vacancy.expires_at + 1.month }
  let(:extension_reason) { Faker::Lorem.paragraph }
  let(:vacancy) { Vacancy.last }

  before do
    Timecop.travel Date.new(2024, 10, 6)

    create(:vacancy, vacancy_type, organisations: [organisation])
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_jobs_with_type_path(vacancy_type)
    click_on vacancy.job_title
    click_on extend_expires_at
  end

  after do
    logout

    Timecop.return
  end

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

    before do
      fill_in "publishers_job_listing_relist_form[expires_at(1i)]", with: expires_at.year
      fill_in "publishers_job_listing_relist_form[expires_at(2i)]", with: expires_at.month
      fill_in "publishers_job_listing_relist_form[expires_at(3i)]", with: expires_at.day
      choose "9am", name: "publishers_job_listing_relist_form[expiry_time]"

      choose I18n.t("publishers.vacancies.extend_deadline.show.extension_reason.didnt_find_right_candidate")
    end

    it "returns an error without a publish date" do
      click_on I18n.t("buttons.relist_vacancy")

      expect(page).to have_content("There is a problem")
    end

    it "can be re-listed for publishing today" do
      choose I18n.t("helpers.label.publishers_job_listing_important_dates_form.publish_on_day_options.today", date: "6 October 2024"),
             name: "publishers_job_listing_relist_form[publish_on_day]"

      click_on I18n.t("buttons.relist_vacancy")

      expect(current_path).to eq(organisation_job_summary_path(vacancy.id))
      expect(vacancy.reload).to have_attributes(extension_reason: "didnt_find_right_candidate",
                                                publish_on: Date.today,
                                                expires_at: expires_at)
    end

    it "can be re-listed for publishing tomorrow" do
      choose I18n.t("helpers.label.publishers_job_listing_important_dates_form.publish_on_day_options.tomorrow", date: "7 October 2024"),
             name: "publishers_job_listing_relist_form[publish_on_day]"

      click_on I18n.t("buttons.relist_vacancy")

      expect(current_path).to eq(organisation_job_summary_path(vacancy.id))
      expect(vacancy.reload).to have_attributes(extension_reason: "didnt_find_right_candidate",
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

        expect(current_path).to eq(organisation_job_summary_path(vacancy.id))
        expect(vacancy.reload).to have_attributes(extension_reason: "didnt_find_right_candidate",
                                                  publish_on: publish_date,
                                                  expires_at: expires_at)
      end
    end
  end
end
