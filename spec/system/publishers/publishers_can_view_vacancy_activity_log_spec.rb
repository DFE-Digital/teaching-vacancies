require "rails_helper"

RSpec.describe "Publishers can view a vacancy's activity log", versioning: true do
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :secondary, :live, organisations: [organisation]) }
  let(:new_salary) { "£50,000 per year" }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_job_path(vacancy.id)
  end

  after { logout }

  it "updates the activity log" do
    click_review_page_change_link(section: "job_details", row: "salary")
    expect(current_path).to eq(organisation_job_build_path(vacancy.id, :pay_package))

    fill_in "publishers_job_listing_pay_package_form[salary]", with: new_salary
    click_on I18n.t("buttons.save_and_continue")

    click_on I18n.t("tabs.activity_log")

    expect(page).to have_content(I18n.t("publishers.activity_log.salary", new_value: new_salary))
    expect(page).to have_content(publisher.papertrail_display_name)
    expect(page).to have_content(vacancy.versions.first.created_at)
  end
end
