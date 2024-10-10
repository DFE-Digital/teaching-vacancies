require "rails_helper"

RSpec.describe "Publishers can extend a deadline" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:expires_at) { vacancy.expires_at + 1.month }
  let(:extension_reason) { Faker::Lorem.paragraph }
  let!(:vacancy) { create(:vacancy, vacancy_type, organisations: [organisation]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_jobs_with_type_path(vacancy_type)
    click_on vacancy.job_title
    click_on I18n.t("publishers.vacancies.show.heading_component.action.extend_closing_date")
  end
  after { logout }

  context "when the vacancy has not expired" do
    let(:vacancy_type) { :published }

    it "submits form, renders error, then extends" do
      choose I18n.t("publishers.vacancies.extend_deadline.show.extension_reason.other_extension_reason"), name: "publishers_job_listing_extend_deadline_form[extension_reason]"
      click_on I18n.t("buttons.extend_closing_date")

      expect(page).to have_content("There is a problem")

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

    scenario "the closing date can be extended" do
      fill_in "publishers_job_listing_extend_deadline_form[expires_at(1i)]", with: expires_at.year
      fill_in "publishers_job_listing_extend_deadline_form[expires_at(2i)]", with: expires_at.month
      fill_in "publishers_job_listing_extend_deadline_form[expires_at(3i)]", with: expires_at.day
      choose "9am", name: "publishers_job_listing_extend_deadline_form[expiry_time]"

      choose I18n.t("publishers.vacancies.extend_deadline.show.extension_reason.didnt_find_right_candidate")

      click_on I18n.t("buttons.extend_closing_date")

      expect(current_path).to eq(organisation_jobs_with_type_path(:published))
      expect(vacancy.reload).to have_attributes(extension_reason: "didnt_find_right_candidate", expires_at: expires_at)
    end
  end
end
