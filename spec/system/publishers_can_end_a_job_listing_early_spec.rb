require "rails_helper"

RSpec.describe "Publishers can end a job listing early" do
  let(:organisation) { create(:school) }
  let!(:vacancy) { create(:vacancy, :published, organisations: [organisation]) }
  let(:publisher) { create(:publisher) }

  before do
    login_publisher(publisher:, organisation:)
    visit organisation_jobs_path
  end

  it "submits form, renders error, then ends listing early" do
    click_on vacancy.job_title
    click_on I18n.t("buttons.end_listing_early")
    click_on I18n.t("buttons.end_listing")

    expect(page).to have_content("There is a problem")

    choose I18n.t("helpers.label.publishers_job_listing_end_listing_form.end_listing_reason_options.suitable_candidate_found")
    select "Teaching Vacancies"

    expect { click_on I18n.t("buttons.end_listing") }.to change { Vacancy.live.count }.from(1).to(0)

    expect(current_path).to eq(jobs_with_type_organisation_path(:expired))
  end
end
