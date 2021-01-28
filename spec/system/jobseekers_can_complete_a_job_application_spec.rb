require "rails_helper"

RSpec.describe "Jobseekers can complete a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:organisation) { create(:school) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows jobseekers to complete application and go to review page" do
    visit jobseekers_job_application_build_path(job_application, :personal_details)

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.personal_details.title"))
    validates_step_complete
    fill_in_personal_details
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.professional_status.title"))
    validates_step_complete
    fill_in_professional_status
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.personal_statement.title"))
    validates_step_complete
    fill_in_personal_statement
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.references.title"))
    expect(page).not_to have_content(I18n.t("buttons.continue"))
    click_on I18n.t("buttons.add_reference")
    click_on I18n.t("jobseekers.job_applications.details.form.references.save")
    expect(page).to have_content("There is a problem")
    fill_in_reference
    click_on I18n.t("jobseekers.job_applications.details.form.references.add_another")
    fill_in_reference
    click_on I18n.t("jobseekers.job_applications.details.form.references.save")
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.ask_for_support.title"))
    validates_step_complete
    fill_in_ask_for_support
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.declarations.title"))
    validates_step_complete
    fill_in_declarations
    click_on I18n.t("buttons.continue")

    expect(current_path).to eq(jobseekers_job_application_review_path(job_application))
    # TODO: Once review page is complete, verify that application data details are correct
    expect(page).to have_content("First name: John")
  end

  def validates_step_complete
    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
  end
end
