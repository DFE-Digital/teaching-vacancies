require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let!(:publisher_preference) { create(:publisher_preference, publisher: publisher, organisation: school_group, schools: [school1, school2]) }
  let(:school_group) { create(:local_authority, schools: [school1, school2]) }
  let(:school1) { create(:school, :not_applicable, name: "First school") }
  let(:school2) { create(:school, :not_applicable, name: "Second school") }
  let(:vacancy) { build(:vacancy, :no_tv_applications, :teacher, :ect_suitable, phases: %w[secondary], organisations: [school1, school2]) }
  let(:created_vacancy) { Vacancy.last }

  before do
    login_publisher(publisher: publisher, organisation: school_group)
    allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
  end

  scenario "publishes a vacancy" do
    visit organisation_path
    click_on I18n.t("buttons.create_job")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_location))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")

    fill_in_job_location_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role))

    fill_in_job_role_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :education_phases))

    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :education_phases))

    fill_in_education_phases_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_title))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_title))

    fill_in_job_title_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :key_stages))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :key_stages))

    fill_in_key_stages_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :subjects))

    fill_in_subjects_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contract_type))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contract_type))

    fill_in_contract_type_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :working_patterns))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :working_patterns))

    fill_in_working_patterns_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

    fill_in_pay_package_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

    fill_in_important_dates_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :start_date))

    fill_in_start_date_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :how_to_receive_applications))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :how_to_receive_applications))

    fill_in_how_to_receive_applications_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :application_link))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :application_link))

    fill_in_application_link_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :school_visits))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :school_visits))

    fill_in_school_visits_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contact_details))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contact_details))

    fill_in_contact_details_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :about_the_role))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :about_the_role))

    fill_in_about_the_role_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :include_additional_documents))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :include_additional_documents))

    fill_in_include_additional_documents_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
    verify_all_vacancy_details(created_vacancy)

    click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
    expect(current_path).to eq(organisation_job_summary_path(created_vacancy.id))
  end
end
