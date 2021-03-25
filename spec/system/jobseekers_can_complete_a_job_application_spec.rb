require "rails_helper"

RSpec.describe "Jobseekers can complete a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:organisation) { create(:school) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows jobseekers to complete an application and go to review page" do
    visit jobseekers_job_application_build_path(job_application, :personal_details)
    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.personal_details.heading"))
    validates_step_complete
    fill_in_personal_details
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.professional_status.heading"))
    validates_step_complete
    fill_in_professional_status
    click_on I18n.t("buttons.save_and_continue")

    # Education and qualifications. There are four different user journeys to test.
    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.qualifications.heading"))
    expect(page).to have_content("No qualifications specified")
    click_on I18n.t("buttons.save_and_continue")
    expect(page).not_to have_content("There is a problem")
    click_on I18n.t("buttons.back")
    # 1. Graduate degrees
    click_on I18n.t("buttons.add_qualification")
    validates_step_complete(button: I18n.t("buttons.continue"))
    choose "Undergraduate degree"
    click_on I18n.t("buttons.continue")
    expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.qualifications_shared.heading.undergraduate"))
    validates_step_complete(button: I18n.t("buttons.save_qualification"))
    fill_in_undergraduate_degree
    click_on I18n.t("buttons.save_qualification")
    # TODO: expect the qualification to be displayed
    # 2. Generic 'other' qualification
    click_on I18n.t("buttons.add_another_qualification")
    choose "Other qualification or course"
    click_on I18n.t("buttons.continue")
    expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.qualifications_shared.heading.other"))
    validates_step_complete(button: I18n.t("buttons.save_qualification"))
    fill_in_other_qualification
    click_on I18n.t("buttons.save_qualification")
    # TODO: expect the qualification to be displayed
    # 3. Common secondary qualifications
    click_on I18n.t("buttons.add_another_qualification")
    choose "GCSE"
    click_on I18n.t("buttons.continue")
    expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.qualifications_shared.heading.gcse"))
    validates_step_complete(button: I18n.t("buttons.save_qualification"))
    fill_in_gcse
    # TODO: fill_in_another_gcse
    click_on I18n.t("buttons.save_qualification")
    # TODO: expect the qualification to be displayed
    #
    # TODO: Can delete and edit GCSE
    # click_on I18n.t("buttons.add_another_qualification")
    # choose "GCSE"
    # click_on I18n.t("buttons.continue")
    # delete_gcse
    # edit_other_gcse
    # click_on I18n.t("buttons.save_qualification")
    # expect the qualifications to be deleted and edited
    #
    # 4. Other secondary qualification
    click_on I18n.t("buttons.add_another_qualification")
    choose "Other secondary qualification"
    click_on I18n.t("buttons.continue")
    expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.qualifications_shared.heading.other_secondary"))
    validates_step_complete(button: I18n.t("buttons.save_qualification"))
    fill_in_secondary_qualification
    # TODO: fill_in_another_secondary_qualification
    click_on I18n.t("buttons.save_qualification")
    # TODO: expect the qualification to be displayed
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.employment_history.heading"))
    expect(page).to have_content("No employment specified")
    validates_step_complete
    click_on I18n.t("buttons.add_employment")
    click_on I18n.t("buttons.save_employment")
    expect(page).to have_content("There is a problem")
    fill_in_employment_history
    click_on I18n.t("buttons.save_employment")
    validates_step_complete
    choose "No", name: "jobseekers_job_application_employment_history_form[gaps_in_employment]"
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.personal_statement.heading"))
    validates_step_complete
    fill_in_personal_statement
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.references.heading"))
    expect(page).not_to have_content(I18n.t("buttons.save_and_continue"))
    click_on I18n.t("buttons.add_reference")
    click_on I18n.t("buttons.save_reference")
    expect(page).to have_content("There is a problem")
    fill_in_reference
    click_on I18n.t("buttons.save_reference")
    click_on I18n.t("buttons.add_another_reference")
    fill_in_reference
    click_on I18n.t("buttons.save_reference")
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.equal_opportunities.heading"))
    validates_step_complete
    fill_in_equal_opportunities
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.ask_for_support.heading"))
    validates_step_complete
    fill_in_ask_for_support
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.declarations.heading"))
    validates_step_complete
    fill_in_declarations
    click_on I18n.t("buttons.save_and_continue")

    expect(current_path).to eq(jobseekers_job_application_review_path(job_application))
  end

  def validates_step_complete(button: I18n.t("buttons.save_and_continue"))
    click_on button
    expect(page).to have_content("There is a problem")
  end
end
