require "rails_helper"

RSpec.describe "Publishers can view a vacancy's activity log", versioning: true do
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :published, contract_type: "permanent", subjects: old_subjects, organisations: [organisation]) }
  let(:new_job_title) { "Demon headmaster wanted" }
  let(:new_contract_type) { "fixed_term" }
  let(:old_subjects) { %w[Mathematics Science] }
  let(:new_subjects) { %w[Computing Dance] }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_job_path(vacancy.id)
  end

  it "updates the activity log" do
    within("#job_details") { click_on "Change" }

    fill_in I18n.t("helpers.label.publishers_job_listing_job_details_form.job_title"), with: new_job_title

    choose I18n.t("helpers.label.publishers_job_listing_job_details_form.contract_type_options.#{new_contract_type}")

    within("#publishers-job-listing-job-details-form-contract-type-fixed-term-conditional") do
      fill_in I18n.t("helpers.label.publishers_job_listing_job_details_form.fixed_term_contract_duration"), with: "6 months"
    end

    old_subjects.each { |subject| uncheck subject }
    new_subjects.each { |subject| check subject }

    click_on I18n.t("buttons.update_job")
    click_on I18n.t("tabs.activity_log")

    expect(page).to have_content(I18n.t("publishers.activity_log.job_title", new_value: new_job_title))
    expect(page).to have_content(I18n.t("publishers.activity_log.contract_type", new_value: new_contract_type.humanize))
    expect(page).to have_content(I18n.t("publishers.activity_log.subjects", new_value: new_subjects.to_sentence, count: new_subjects.count))
    expect(page).to have_content(publisher.papertrail_display_name)
    expect(page).to have_content(vacancy.versions.first.created_at)
  end
end
