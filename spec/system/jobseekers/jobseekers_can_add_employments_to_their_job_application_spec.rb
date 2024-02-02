require "rails_helper"

RSpec.describe "Jobseekers can add employments and breaks to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let!(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  it "allows jobseekers to add a current role" do
    visit jobseekers_job_application_build_path(job_application, :employment_history)

    expect(page).to have_content("No employment specified")

    click_on I18n.t("buttons.add_job")
    expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_job_application_build_path(job_application, :employment_history))
    validates_step_complete(button: I18n.t("buttons.save_employment"))

    fill_in_current_role

    click_on I18n.t("buttons.save_employment")

    expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :employment_history))
    expect(page).to have_content("The Best Teacher")
    expect(page).to have_content("English KS1")
  end

  it "allows jobseekers to add employment history" do
    visit jobseekers_job_application_build_path(job_application, :employment_history)

    click_on I18n.t("buttons.add_job")
    validates_step_complete(button: I18n.t("buttons.save_employment"))

    fill_in_employment_history

    click_on I18n.t("buttons.save_employment")

    expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :employment_history))
    expect(page).to have_content("The Best Teacher")
    expect(page).to have_content(Date.new(2020, 0o7, 1).to_formatted_s(:month_year))
  end

  it "displays employment history from newest to oldest job" do
    visit jobseekers_job_application_build_path(job_application, :employment_history)

    click_on I18n.t("buttons.add_job")
    validates_step_complete(button: I18n.t("buttons.save_employment"))

    fill_in_employment_history(job_title: "Old job")

    click_on I18n.t("buttons.save_employment")

    all(:link, "Add another job").first.click

    fill_in_employment_history(job_title: "Oldest job", start_month: "09", start_year: "2015", end_month: "06", end_year: "2019")

    click_on I18n.t("buttons.save_employment")

    all(:link, "Add another job").first.click

    fill_in_current_role

    click_on I18n.t("buttons.save_employment")

    oldest_job = find("h3", text: "Oldest job").path
    middle_job = find("h3", text: "Old job").path
    newest_job = find("h3", text: "The Best Teacher").path

    expect(newest_job).to be < middle_job
    expect(newest_job).to be < oldest_job
    expect(middle_job).to be < oldest_job
  end

  context "managing employment history gaps" do
    before do
      create(:employment, :job, job_application: job_application, started_on: Date.parse("2021-01-01"), ended_on: Date.parse("2021-02-01"))
      create(:employment, :job, job_application: job_application, started_on: Date.parse("2021-06-01"), current_role: "yes")
    end

    it "allows jobseekers to add, change and delete gaps in employment with prefilled start and end date" do
      visit jobseekers_job_application_build_path(job_application, :employment_history)
      expect(page).to have_content "You have a break in your work history (4 months)"
      click_on I18n.t("buttons.add_reason_for_break")

      expect(page).to have_field("jobseekers_break_form_started_on_1i", with: "2021")
      expect(page).to have_field("jobseekers_break_form_started_on_2i", with: "2")
      expect(page).to have_field("jobseekers_break_form_ended_on_1i", with: "2021")
      expect(page).to have_field("jobseekers_break_form_ended_on_2i", with: "6")

      click_on I18n.t("buttons.continue")

      expect(page).to have_content("There is a problem")

      fill_in "Enter reasons for gap in work history", with: "Travelling around the world"
      click_on I18n.t("buttons.continue")

      expect(page).to have_content("Travelling around the world")
      expect(page).to have_content("February 2021 to June 2021")

      click_on "Change Break in work history 2021-02-01 to 2021-06-01"

      fill_in "Enter reasons for gap in work history", with: ""
      click_on I18n.t("buttons.continue")

      expect(page).to have_content("There is a problem")

      fill_in "Enter reasons for gap in work history", with: "Looking after my needy turtle"
      click_on I18n.t("buttons.continue")

      expect(page).to have_content("Looking after my needy turtle")

      click_on "Delete Break in work history 2021-02-01 to 2021-06-01"
      click_on I18n.t("buttons.confirm_destroy")

      expect(page).not_to have_content("Looking after my needy turtle")
    end
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

      click_on I18n.t("buttons.change")

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
