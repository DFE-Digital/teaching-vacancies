require "rails_helper"

# same test as publish_as_a_school and as_a_la
# with same defects in error checking.
# 1 good extra error check test
# runtime 9.54 seconds
RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school_group) { create(:trust, schools: [school1, school2, school3], safeguarding_information: nil) }
  let(:school1) { create(:school, :not_applicable, name: "First school") }
  let(:school2) { create(:school, :not_applicable, name: "Second school") }
  let(:school3) { create(:school, :closed, name: "Closed school") }
  let(:vacancy) { build(:vacancy, :no_tv_applications, :central_office, :ect_suitable, job_roles: ["teacher"], organisations: [school_group], phases: %w[secondary], key_stages: %w[ks3]) }
  let(:created_vacancy) { Vacancy.last }

  after { logout }

  scenario "publishes a vacancy" do
    login_publisher(publisher: publisher, organisation: school_group)
    visit organisation_jobs_with_type_path
    click_on I18n.t("buttons.create_job")
    expect(current_path).to eq(organisation_jobs_start_path)
    click_on I18n.t("buttons.create_job")
    expect(publisher_job_location_page).to be_displayed
    uncheck I18n.t("organisations.job_location_heading.central_office")
    click_on I18n.t("buttons.continue")

    expect(publisher_job_location_page).to be_displayed
    expect(publisher_job_location_page).to be_displayed
    expect(publisher_job_location_page.errors.map(&:text)).to contain_exactly(I18n.t("job_location_errors.organisation_ids.blank"))
    publisher_job_location_page.fill_in_and_submit_form(vacancy)

    expect(publisher_job_title_page).to be_displayed
    submit_empty_form
    expect(publisher_job_title_page).to be_displayed
    expect(publisher_job_title_page.errors.map(&:text)).to contain_exactly(I18n.t("job_title_errors.job_title.blank"))
    publisher_job_title_page.fill_in_and_submit_form(vacancy.job_title)

    expect(publisher_job_role_page).to be_displayed
    submit_empty_form
    expect(publisher_job_role_page).to be_displayed
    expect(publisher_job_role_page.errors.map(&:text)).to contain_exactly(I18n.t("job_roles_errors.job_roles.blank"))
    publisher_job_role_page.fill_in_and_submit_form(vacancy.job_roles.first)

    expect(publisher_education_phase_page).to be_displayed
    submit_empty_form
    expect(publisher_education_phase_page).to be_displayed
    expect(publisher_education_phase_page.errors.map(&:text)).to contain_exactly(I18n.t("education_phases_errors.phases.blank"))
    publisher_education_phase_page.fill_in_and_submit_form(vacancy)

    expect(publisher_key_stage_page).to be_displayed
    submit_empty_form
    expect(publisher_key_stage_page).to be_displayed
    expect(publisher_key_stage_page.errors.map(&:text)).to contain_exactly(I18n.t("key_stages_errors.key_stages.blank"))
    publisher_key_stage_page.fill_in_and_submit_form(vacancy.key_stages_for_phases)

    expect(publisher_subjects_page).to be_displayed
    publisher_subjects_page.fill_in_and_submit_form(vacancy.subjects)

    expect(publisher_contract_information_page).to be_displayed
    submit_empty_form
    expect(publisher_contract_information_page).to be_displayed
    expect(publisher_contract_information_page.errors.map(&:text)).to contain_exactly(
      I18n.t("contract_information_errors.contract_type.inclusion"),
      I18n.t("contract_information_errors.working_patterns.inclusion"),
      I18n.t("contract_information_errors.is_job_share.inclusion"),
    )
    publisher_contract_information_page.fill_in_and_submit_form(vacancy)

    expect(publisher_start_date_page).to be_displayed
    submit_empty_form
    expect(publisher_start_date_page).to be_displayed
    expect(publisher_start_date_page.errors.map(&:text)).to contain_exactly(I18n.t("start_date_errors.start_date_type.inclusion"))
    publisher_start_date_page.fill_in_and_submit_form(vacancy.starts_on)

    expect(publisher_pay_package_page).to be_displayed
    submit_empty_form
    expect(publisher_pay_package_page).to be_displayed
    expect(publisher_pay_package_page.errors.map(&:text)).to contain_exactly(
      I18n.t("pay_package_errors.salary_types.invalid"),
      I18n.t("pay_package_errors.benefits.inclusion"),
    )
    expect_correct_pay_package_options(vacancy)
    publisher_pay_package_page.fill_in_and_submit_form(vacancy)

    expect(publisher_about_the_role_page).to be_displayed
    submit_empty_form
    expect(publisher_about_the_role_page).to be_displayed
    expect(publisher_about_the_role_page.errors.map(&:text)).to contain_exactly(
      I18n.t("about_the_role_errors.ect_status.inclusion"),
      I18n.t("about_the_role_errors.skills_and_experience.blank"),
      I18n.t("about_the_role_errors.further_details_provided.inclusion"),
      I18n.t("about_the_role_errors.school_offer.blank", organisation: "trust"),
      I18n.t("about_the_role_errors.flexi_working_details_provided.inclusion"),
    )
    publisher_about_the_role_page.fill_in_and_submit_form(vacancy)

    expect(publisher_include_additional_documents_page).to be_displayed
    submit_empty_form
    expect(publisher_include_additional_documents_page.errors.map(&:text)).to contain_exactly(I18n.t("include_additional_documents_errors.include_additional_documents.inclusion"))
    publisher_include_additional_documents_page.fill_in_and_submit_form(vacancy.include_additional_documents)

    expect(publisher_school_visits_page).to be_displayed
    submit_empty_form
    expect(publisher_school_visits_page).to be_displayed
    expect(publisher_school_visits_page.errors.map(&:text)).to contain_exactly(I18n.t("school_visits_errors.school_visits.inclusion"))
    publisher_school_visits_page.fill_in_and_submit_form(vacancy)

    expect(publisher_visa_sponsorship_page).to be_displayed
    submit_empty_form
    expect(publisher_visa_sponsorship_page.errors.map(&:text)).to contain_exactly(I18n.t("visa_sponsorship_available_errors.visa_sponsorship_available.inclusion"))
    expect(publisher_visa_sponsorship_page).to be_displayed
    publisher_visa_sponsorship_page.fill_in_and_submit_form(vacancy)

    expect(publisher_important_dates_page).to be_displayed
    submit_empty_form
    expect(publisher_important_dates_page).to be_displayed
    expect(publisher_important_dates_page.errors.map(&:text)).to contain_exactly(
      I18n.t("important_dates_errors.publish_on_day.inclusion"),
      I18n.t("important_dates_errors.expires_at.blank"),
      I18n.t("important_dates_errors.expiry_time.inclusion"),
    )
    publisher_important_dates_page.fill_in_and_submit_form(publish_on: vacancy.publish_on, expires_at: vacancy.expires_at)

    expect(publisher_applying_for_the_job_page).to be_displayed
    submit_empty_form
    expect(publisher_applying_for_the_job_page).to be_displayed
    expect(publisher_applying_for_the_job_page.errors.map(&:text)).to contain_exactly(I18n.t("applying_for_the_job_errors.application_form_type.blank"))
    publisher_applying_for_the_job_page.fill_in_and_submit_form

    expect(publisher_how_to_receive_applications_page).to be_displayed
    submit_empty_form
    expect(publisher_how_to_receive_applications_page).to be_displayed
    expect(publisher_how_to_receive_applications_page.errors.map(&:text)).to contain_exactly(I18n.t("how_to_receive_applications_errors.receive_applications.inclusion"))
    publisher_how_to_receive_applications_page.fill_in_and_submit_form(vacancy)

    expect(publisher_application_link_page).to be_displayed
    submit_empty_form
    expect(publisher_application_link_page.errors.map(&:text)).to contain_exactly(I18n.t("application_link_errors.application_link.blank"))
    expect(publisher_application_link_page).to be_displayed
    publisher_application_link_page.fill_in_and_submit_form(vacancy)

    expect(publisher_contact_details_page).to be_displayed
    submit_empty_form
    expect(publisher_contact_details_page.errors.map(&:text)).to contain_exactly(
      I18n.t("contact_details_errors.contact_email.blank"),
      I18n.t("contact_details_errors.contact_number_provided.inclusion"),
    )
    expect(publisher_contact_details_page).to be_displayed
    publisher_contact_details_page.fill_in_and_submit_form(vacancy)

    expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))

    click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
    expect(current_path).to eq(organisation_job_summary_path(created_vacancy.id))
  end

  def submit_empty_form
    click_on I18n.t("buttons.save_and_continue")
  end
end
