require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let!(:publisher_preference) { create(:publisher_preference, publisher: publisher, organisation: school_group, schools: [school1, school2]) }
  let(:school_group) { create(:local_authority, schools: [school1, school2]) }
  let(:school1) { create(:school, name: "First school") }
  let(:school2) { create(:school, name: "Second school") }
  let(:vacancy) { build(:vacancy, :at_one_school, :no_tv_applications, :teacher, :ect_suitable, organisations: [school1, school2]) }
  let(:created_vacancy) { Vacancy.last }

  before do
    login_publisher(publisher: publisher, organisation: school_group)
    allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
  end

  scenario "resets session current_step" do
    page.set_rack_session(current_step: :review)

    visit organisation_path
    click_on I18n.t("buttons.create_job")

    fill_in_job_role_form_fields(vacancy)
    click_on I18n.t("buttons.continue")

    expect(page.get_rack_session["current_step"]).to be nil
  end

  scenario "publishes a vacancy" do
    visit organisation_path
    click_on I18n.t("buttons.create_job")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")

    fill_in_job_role_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role_details))

    fill_in_ect_status_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_location))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_location))

    fill_in_job_location_form_field(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_details))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_details))

    fill_in_job_details_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :working_patterns))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :working_patterns))

    fill_in_working_patterns_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

    fill_in_pay_package_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

    fill_in_important_dates_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job_details))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_application_forms_path(created_vacancy.id))

    fill_in_applying_for_the_job_details_form_fields(vacancy, local_authority_vacancy: true)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_documents_path(created_vacancy.id))

    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_summary))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_summary))

    fill_in_job_summary_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
    verify_all_vacancy_details(created_vacancy)

    click_on I18n.t("buttons.submit_job_listing")
    expect(current_path).to eq(organisation_job_summary_path(created_vacancy.id))
  end
end
