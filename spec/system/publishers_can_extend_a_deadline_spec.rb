require "rails_helper"

RSpec.describe "Publishers can extend a deadline" do
  let(:organisation) { create(:school) }
  let!(:vacancy) { create(:vacancy, :published, organisations: [organisation]) }
  let(:publisher) { create(:publisher) }
  let(:expires_at) { vacancy.expires_at + 1.month }

  before do
    login_publisher(publisher:, organisation:)
    visit jobs_with_type_organisation_path(:published)
  end

  it "submits form, renders error, then ends listing early" do
    click_on vacancy.job_title
    click_on I18n.t("buttons.extend_deadline")
    click_on I18n.t("buttons.extend_deadline")

    expect(page).to have_content("There is a problem")

    fill_in "publishers_job_listing_extend_deadline_form[expires_at(1i)]", with: expires_at.year
    fill_in "publishers_job_listing_extend_deadline_form[expires_at(2i)]", with: expires_at.month
    fill_in "publishers_job_listing_extend_deadline_form[expires_at(3i)]", with: expires_at.day
    choose "9am", name: "publishers_job_listing_extend_deadline_form[expiry_time]"

    click_on I18n.t("buttons.extend_deadline")

    expect(current_path).to eq(jobs_with_type_organisation_path(:published))
  end
end
