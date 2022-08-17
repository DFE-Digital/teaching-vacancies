require "rails_helper"

RSpec.describe "Publishers can view a vacancy's activity log", versioning: true do
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :published, contract_type: "permanent", subjects: old_subjects, phases: %w[secondary], organisations: [organisation], key_stages: %w[ks3]) }
  let(:new_job_title) { "Demon headmaster wanted" }
  let(:new_contract_type) { "fixed_term" }
  let(:old_subjects) { %w[Mathematics Science] }
  let(:new_subjects) { %w[Computing Dance] }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_job_path(vacancy.id)
  end

  it "updates the activity log" do
    click_review_page_change_link(section: "job_details", row: "subjects")
    expect(current_path).to eq(organisation_job_build_path(vacancy.id, :subjects))

    old_subjects.each { |subject| uncheck subject }
    new_subjects.each { |subject| check subject }

    click_on I18n.t("buttons.save_and_continue")

    click_review_page_change_link(section: "job_details", row: "contract_type")
    expect(current_path).to eq(organisation_job_build_path(vacancy.id, :contract_type))

    choose I18n.t("helpers.label.publishers_job_listing_contract_type_form.contract_type_options.#{new_contract_type}")
    within("#publishers-job-listing-contract-type-form-contract-type-fixed-term-conditional") do
      fill_in I18n.t("helpers.label.publishers_job_listing_contract_type_form.fixed_term_contract_duration"), with: "6 months"
    end

    click_on I18n.t("buttons.save_and_continue")

    click_on I18n.t("tabs.activity_log")

    expect(page).to have_content(I18n.t("publishers.activity_log.subjects", new_value: new_subjects.to_sentence, count: new_subjects.count))
    expect(page).to have_content(I18n.t("publishers.activity_log.contract_type", new_value: new_contract_type.humanize))
    expect(page).to have_content(publisher.papertrail_display_name)
    expect(page).to have_content(vacancy.versions.first.created_at)
  end
end
