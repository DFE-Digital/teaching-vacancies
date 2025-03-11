require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school_group) { create(:trust, schools: [school1, school2, school3], safeguarding_information: nil) }
  let(:school1) { create(:school, :not_applicable, name: "First school") }
  let(:school2) { create(:school, :not_applicable, name: "Second school") }
  let(:school3) { create(:school, :closed, name: "Closed school") }
  let(:vacancy) { build(:vacancy, :central_office, :ect_suitable, job_roles: ["teacher"], organisations: [school_group], phases: %w[secondary], key_stages: %w[ks3]) }
  let(:created_vacancy) { Vacancy.last }

  before do
    login_publisher(publisher: publisher, organisation: school_group)

    visit organisation_jobs_with_type_path
    click_on I18n.t("buttons.create_job")
  end

  after { logout }

  describe "the job location step" do
    scenario "displays error message unless a location is selected" do
      expect(current_path).to eq(new_organisation_job_path)
      click_on I18n.t("buttons.create_job")
      expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 1, total: 4))
      within("h1") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.job_location"))
      end

      uncheck I18n.t("organisations.job_location_heading.central_office")

      click_on I18n.t("buttons.continue")

      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("job_location_errors.organisation_ids.blank"))
      end
    end

    scenario "redirects to job details when submitted successfully" do
      expect(current_path).to eq(new_organisation_job_path)
      click_on I18n.t("buttons.create_job")
      expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 1, total: 4))
      within("h1") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.job_location"))
      end

      fill_in_job_location_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 1, total: 4))
      within("h1") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.job_title"))
      end
    end
  end

  scenario "publishes a vacancy" do
    expect(current_path).to eq(new_organisation_job_path)
    click_on I18n.t("buttons.create_job")
    uncheck I18n.t("organisations.job_location_heading.central_office")
    click_on I18n.t("buttons.continue")

    expect(page).to have_content("There is a problem")

    fill_in_job_location_form_fields(vacancy)
    click_on I18n.t("buttons.continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_title))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_title))

    fill_in_job_title_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role))

    fill_in_job_role_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :education_phases))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :education_phases))

    fill_in_education_phases_form_fields(vacancy)
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

    expect_correct_pay_package_options(vacancy)

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

    choose I18n.t("helpers.legend.publishers_job_listing_start_date_form.asap")
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

    find('label[for="publishers-job-listing-applying-for-the-job-form-application-form-type-no-religion-field"]').click
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :school_visits))

    fill_in_school_visits_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :visa_sponsorship))

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_content("There is a problem")
    expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :visa_sponsorship))

    fill_in_visa_sponsorship_form_fields(vacancy)
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
