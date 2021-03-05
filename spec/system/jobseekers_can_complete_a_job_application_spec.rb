require "rails_helper"

RSpec.describe "Jobseekers can complete a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:organisation) { create(:school) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows jobseekers to complete an application and go to review page" do
    visit job_path(vacancy)

    click_on I18n.t("jobseekers.job_applications.apply")
    click_on I18n.t("buttons.start_application")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.personal_details.heading"))
    validates_step_complete
    fill_in_personal_details
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.professional_status.heading"))
    validates_step_complete
    fill_in_professional_status
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.employment_history.heading"))
    validates_step_complete
    click_on I18n.t("buttons.add_role")
    click_on I18n.t("jobseekers.job_applications.details.form.employment_history.save")
    expect(page).to have_content("There is a problem")
    fill_in_employment_history
    click_on I18n.t("jobseekers.job_applications.details.form.employment_history.save")
    validates_step_complete
    choose "No", name: "jobseekers_job_application_employment_history_form[gaps_in_employment]"
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.personal_statement.heading"))
    validates_step_complete
    fill_in_personal_statement
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.references.heading"))
    expect(page).not_to have_content(I18n.t("buttons.continue"))
    click_on I18n.t("buttons.add_reference")
    click_on I18n.t("jobseekers.job_applications.details.form.references.save")
    expect(page).to have_content("There is a problem")
    fill_in_reference
    click_on I18n.t("jobseekers.job_applications.details.form.references.save")
    click_on I18n.t("buttons.add_another_reference")
    fill_in_reference
    click_on I18n.t("jobseekers.job_applications.details.form.references.save")
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.equal_opportunities.heading"))
    validates_step_complete
    fill_in_equal_opportunities
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.ask_for_support.heading"))
    validates_step_complete
    fill_in_ask_for_support
    click_on I18n.t("buttons.continue")

    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.declarations.heading"))
    validates_step_complete
    fill_in_declarations
    click_on I18n.t("buttons.continue")

    expect(current_path).to eq(jobseekers_job_application_review_path(jobseeker.job_applications.last))
  end

  context "when the listing expires during the application process" do
    context "when the controller is the BuildController" do
      it "redirects to the expiry page" do
        visit new_jobseekers_job_job_application_path(vacancy.id)

        click_on I18n.t("buttons.start_application")
        fill_in_personal_details

        redirects_to_expired_page
      end
    end

    context "when the controller is the DetailsController" do
      let(:job_application) do
        create(:job_application,
               completed_steps: %i[personal_details professional_status],
               jobseeker: jobseeker,
               vacancy: vacancy)
      end

      it "redirects to the expiry page" do
        visit jobseekers_job_application_build_path(job_application, :employment_history)
        redirects_to_expired_page
      end
    end

    context "when the controller is the JobApplicationsController" do
      context "when the next step is the review step" do
        let(:job_application) do
          create(:job_application,
                 completed_steps: JobApplication.completed_steps.keys.without(:declarations),
                 jobseeker: jobseeker,
                 vacancy: vacancy)
        end

        it "redirects to the expiry page" do
          visit jobseekers_job_application_build_path(job_application, :declarations)

          redirects_to_expired_page
        end
      end
    end
  end

  def validates_step_complete
    click_on I18n.t("buttons.continue")
    expect(page).to have_content("There is a problem")
  end
end
