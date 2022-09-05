require "rails_helper"

RSpec.describe "Publishers can extend a deadline" do
  let(:organisation) { create(:school) }
  let!(:vacancy) { create(:vacancy, :published, organisations: [organisation]) }
  let(:publisher) { create(:publisher) }
  let(:expires_at) { vacancy.expires_at + 1.month }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  it "submits form, renders error, then ends listing early" do
    visit jobs_with_type_organisation_path(:published)
    click_on vacancy.job_title
    click_on I18n.t("publishers.vacancies.show.heading_component.action.extend_closing_date")
    click_on I18n.t("buttons.extend_closing_date")

    expect(page).to have_content("There is a problem")

    fill_in "publishers_job_listing_extend_deadline_form[expires_at(1i)]", with: expires_at.year
    fill_in "publishers_job_listing_extend_deadline_form[expires_at(2i)]", with: expires_at.month
    fill_in "publishers_job_listing_extend_deadline_form[expires_at(3i)]", with: expires_at.day
    choose "9am", name: "publishers_job_listing_extend_deadline_form[expiry_time]"

    click_on I18n.t("buttons.extend_closing_date")

    expect(current_path).to eq(jobs_with_type_organisation_path(:published))
  end

  context "when the vacancy has expired" do
    let!(:expired_vacancy) { create(:vacancy, :expired, organisations: [organisation]) }

    before { visit jobs_with_type_organisation_path(:expired) }

    scenario "the closing date can be extended" do
      click_on expired_vacancy.job_title
      click_on I18n.t("publishers.vacancies.show.heading_component.action.extend_closing_date")

      fill_in "publishers_job_listing_extend_deadline_form[expires_at(1i)]", with: expires_at.year
      fill_in "publishers_job_listing_extend_deadline_form[expires_at(2i)]", with: expires_at.month
      fill_in "publishers_job_listing_extend_deadline_form[expires_at(3i)]", with: expires_at.day
      choose "9am", name: "publishers_job_listing_extend_deadline_form[expiry_time]"

      click_on I18n.t("buttons.extend_closing_date")

      expect(current_path).to eq(jobs_with_type_organisation_path(:published))
    end
  end
end
