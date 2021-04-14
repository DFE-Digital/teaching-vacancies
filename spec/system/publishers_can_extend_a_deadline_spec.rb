require "rails_helper"

RSpec.describe "Publishers can extend a deadline" do
  let(:organisation) { create(:school) }
  let!(:vacancy) { create(:vacancy, :published, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:publisher) { create(:publisher) }
  let(:expires_on) { vacancy.expires_at + 1.month }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit jobs_with_type_organisation_path(:published)
  end

  it "submits form, renders error, then ends listing early" do
    click_on I18n.t("jobs.manage.extend_link_text")

    click_on I18n.t("buttons.extend_deadline")

    expect(page).to have_content("There is a problem")

    fill_in "publishers_job_listing_extend_deadline_form[expires_on(1i)]", with: expires_on.year
    fill_in "publishers_job_listing_extend_deadline_form[expires_on(2i)]", with: expires_on.month
    fill_in "publishers_job_listing_extend_deadline_form[expires_on(3i)]", with: expires_on.day
    choose "Start of the working day (9 am)", name: "publishers_job_listing_extend_deadline_form[expiry_time]"

    click_on I18n.t("buttons.extend_deadline")

    expect(current_path).to eq(jobs_with_type_organisation_path(:published))
  end
end
