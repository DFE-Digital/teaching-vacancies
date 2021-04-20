require "rails_helper"

RSpec.describe "Jobseekers can add employments to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows jobseekers to add a current role" do
    visit jobseekers_job_application_build_path(job_application, :employment_history)

    expect(page).to have_content("No employment specified")

    click_on I18n.t("buttons.add_employment")
    validates_step_complete(button: I18n.t("buttons.save_employment"))

    fill_in_current_role

    click_on I18n.t("buttons.save_employment")

    expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :employment_history))
    expect(page).to have_content("The Best Teacher")
  end

  it "allows jobseekers to add employment history" do
    visit jobseekers_job_application_build_path(job_application, :employment_history)

    click_on I18n.t("buttons.add_employment")
    validates_step_complete(button: I18n.t("buttons.save_employment"))

    fill_in_employment_history

    click_on I18n.t("buttons.save_employment")

    expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :employment_history))
    expect(page).to have_content("The Best Teacher")
    expect(page).to have_content(Date.new(2020, 0o7, 30).to_s)
  end

  it "allows jobseekers to add gaps in employment" do
    visit jobseekers_job_application_build_path(job_application, :employment_history)

    choose "Yes", name: "jobseekers_job_application_employment_history_form[gaps_in_employment]"
    fill_in "jobseekers_job_application_employment_history_form[gaps_in_employment_details]", with: "Some details about gaps in employment"
    click_on I18n.t("buttons.save_and_come_back")

    expect(job_application.reload.gaps_in_employment).to eq("yes")
    expect(job_application.reload.gaps_in_employment_details).to eq("Some details about gaps in employment")
  end

  context "when there is at least one role" do
    let!(:employment) { create(:employment, organisation: "A school", job_application: job_application) }

    it "allows jobseekers to delete employment history" do
      visit jobseekers_job_application_build_path(job_application, :employment_history)

      click_on I18n.t("buttons.delete")

      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :employment_history))
      expect(page).to have_content(I18n.t("jobseekers.job_applications.employments.destroy.success"))
      expect(page).not_to have_content("Teacher")
    end

    it "allows jobseekers to edit employment history" do
      visit jobseekers_job_application_build_path(job_application, :employment_history)

      click_on I18n.t("buttons.edit")

      fill_in "School or other organisation", with: ""
      validates_step_complete(button: I18n.t("buttons.save_employment"))

      fill_in "School or other organisation", with: "A different school"
      click_on I18n.t("buttons.save_employment")

      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :employment_history))
      expect(page).not_to have_content("A school")
      expect(page).to have_content("A different school")
    end
  end
end
