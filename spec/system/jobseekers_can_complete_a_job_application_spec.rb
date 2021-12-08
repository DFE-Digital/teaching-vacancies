require "rails_helper"

RSpec.describe "Jobseekers can complete a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [organisation], job_roles: %w[teacher]) }
  let(:organisation) { create(:school) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  it "allows jobseekers to complete an application and go to review page" do
    visit jobseekers_job_application_build_path(job_application, :personal_details)
    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.personal_details.heading"))
    expect(page).to have_field("Email address", with: jobseeker.email)
    validates_step_complete
    fill_in_personal_details
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.professional_status.heading"))
    validates_step_complete
    fill_in_professional_status
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.qualifications.heading"))
    click_on I18n.t("buttons.save_and_continue")
    expect(page).not_to have_content("There is a problem")
    click_on I18n.t("buttons.back")
    click_on I18n.t("buttons.add_qualification")
    validates_step_complete(button: I18n.t("buttons.continue"))
    select_qualification_category("Undergraduate degree")
    expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.undergraduate"))
    validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
    fill_in_undergraduate_degree
    click_on I18n.t("buttons.save_qualification.one")
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.employment_history.heading"))
    click_on I18n.t("buttons.add_job")
    click_on I18n.t("buttons.save_employment")
    expect(page).to have_content("There is a problem")
    fill_in_employment_history
    click_on I18n.t("buttons.save_employment")
    click_on I18n.t("buttons.add_another_break")
    fill_in_break_in_employment
    click_on I18n.t("buttons.continue")
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
end
