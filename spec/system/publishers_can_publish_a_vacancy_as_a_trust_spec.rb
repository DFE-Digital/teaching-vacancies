require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school_group) { create(:trust, schools: [school1, school2, school3]) }
  let(:school1) { create(:school, :not_applicable, name: "First school") }
  let(:school2) { create(:school, :not_applicable, name: "Second school") }
  let(:school3) { create(:school, :closed, name: "Closed school") }
  let(:vacancy) { build(:vacancy, :central_office, :teacher, :ect_suitable, organisations: [school_group], phases: %w[secondary], key_stages: %w[ks3]) }
  let(:created_vacancy) { Vacancy.last }

  before do
    login_publisher(publisher: publisher, organisation: school_group)
    allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
  end

  describe "the job location step" do
    scenario "displays error message unless a location is selected" do
      visit organisation_path
      click_on I18n.t("buttons.create_job")

      expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 1, total: 4))
      within("h1.govuk-heading-l") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.job_location"))
      end

      click_on I18n.t("buttons.continue")

      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("job_location_errors.organisation_ids.blank"))
      end
    end

    scenario "redirects to job details when submitted successfully" do
      visit organisation_path
      click_on I18n.t("buttons.create_job")

      expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 1, total: 4))
      within("h1.govuk-heading-l") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.job_location"))
      end

      fill_in_job_location_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 1, total: 4))
      within("h1.govuk-heading-l") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.job_role"))
      end
    end
  end

  scenario "publishes a vacancy" do
    visit organisation_path
    click_on I18n.t("buttons.create_job")

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
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

    fill_in_applying_for_the_job_form_fields(vacancy, local_authority_vacancy: false)
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
    expect(current_path).to eq(organisation_job_path(created_vacancy.id))
    verify_all_vacancy_details(created_vacancy)
    has_complete_draft_vacancy_review_heading?(vacancy)

    click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
    expect(current_path).to eq(organisation_job_summary_path(created_vacancy.id))
  end
end
