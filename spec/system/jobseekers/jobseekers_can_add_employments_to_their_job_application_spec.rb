require "rails_helper"

RSpec.describe "Jobseekers can add employments and breaks to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let!(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy, employments: employments) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_build_path(job_application, :employment_history)
  end

  after { logout }

  context "with no employment history" do
    let(:employments) { [] }

    it "allows jobseekers to add employment history, including a current role" do
      click_on I18n.t("buttons.add_work_history")
      expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_job_application_build_path(job_application, :employment_history))
      validates_step_complete(button: I18n.t("buttons.save_employment"))
      fill_in_current_role(form: "jobseekers_job_application_details_employment_form")

      click_on I18n.t("buttons.save_employment")

      expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :employment_history), ignore_query: true)
      expect(page).to have_content("The Best Teacher")
      expect(page).to have_content("English KS1")

      click_on I18n.t("buttons.add_work_history")
      validates_step_complete(button: I18n.t("buttons.save_employment"))

      fill_in_employment_history(job_title: "Another teaching job")

      click_on I18n.t("buttons.save_employment")

      expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :employment_history), ignore_query: true)
      expect(page).to have_content("Another teaching job")
      expect(page).to have_content(Date.new(2020, 7, 1).to_formatted_s(:month_year))
    end
  end

  context "with an employmeent history" do
    let(:employments) do
      [
        build(:employment, job_title: "Old job", started_on: Date.new(2019, 7, 1), ended_on: Date.new(2020, 7, 1)),
        build(:employment, :current_role, job_title: "The Best Teacher", started_on: Date.new(2020, 7, 1)),
      ]
    end

    before do
      build(:employment, reason_for_leaving: nil, job_application: job_application, job_title: "Oldest job",
                         started_on: Date.new(2015, 7, 1), ended_on: Date.new(2019, 7, 1)).save!(validate: false)
      visit current_path
    end

    it "passes a11y", :a11y do
      # lists are not allowed to have direct 'a' children
      expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner", "list"
    end

    it "displays employment history from newest to oldest job, shows any errors and prevents saving until fixed" do
      expect(all(".govuk-summary-card__title").map(&:text)).to eq ["The Best Teacher", "Old job", "Oldest job"]

      expect(all(".govuk-summary-card__content").last).to have_content "Enter your reason for leaving this role"

      choose "Yes, I've completed this section"
      validates_step_complete(button: "Save and continue")

      within all(".govuk-summary-card").last do
        click_on "Change"
      end
      fill_in "Reason for leaving role", with: "Needed for KSCIE compliance"
      click_on I18n.t("buttons.save_employment")
      choose "Yes, I've completed this section"
      click_on "Save and continue"
      expect(page).to have_current_path(jobseekers_job_application_apply_path(job_application))
    end
  end

  context "managing employment history gaps" do
    let(:employments) do
      [
        build(:employment, :job, started_on: Date.parse("2021-01-01"), ended_on: Date.parse("2021-02-01")),
        build(:employment, :job, :current_role, started_on: Date.parse("2021-06-01")),
      ]
    end

    it "allows jobseekers to add, change and delete gaps in employment with prefilled start and end date" do
      expect(page).to have_content "You have a gap in your work history from February 2021 to June 2021 (4 months)"
      click_on I18n.t("buttons.add_reason_for_break")

      expect(page).to have_field("jobseekers_break_form_started_on_1i", with: "2021")
      expect(page).to have_field("jobseekers_break_form_started_on_2i", with: "2")
      expect(page).to have_field("jobseekers_break_form_ended_on_1i", with: "2021")
      expect(page).to have_field("jobseekers_break_form_ended_on_2i", with: "6")

      click_on I18n.t("buttons.continue")

      expect(page).to have_content("There is a problem")
      within "ul.govuk-list.govuk-error-summary__list" do
        expect(page).to have_link("Enter a reason for this gap")
      end

      fill_in "Enter reasons for gap in work history", with: "Travelling around the world"
      click_on I18n.t("buttons.continue")

      expect(page).to have_content("Travelling around the world")
      expect(page).to have_content("February 2021 to June 2021")

      click_on "Change Gap in work history 2021-02-01 to 2021-06-01"

      fill_in "Enter reasons for gap in work history", with: ""
      click_on I18n.t("buttons.continue")

      expect(page).to have_content("There is a problem")
      within "ul.govuk-list.govuk-error-summary__list" do
        expect(page).to have_link("Enter a reason for this gap")
      end

      fill_in "Enter reasons for gap in work history", with: "Looking after my needy turtle"
      click_on I18n.t("buttons.continue")

      expect(page).to have_content("Looking after my needy turtle")

      click_on "Delete Gap in work history 2021-02-01 to 2021-06-01"
      click_on I18n.t("buttons.confirm_destroy")

      expect(page).not_to have_content("Looking after my needy turtle")
    end
  end

  context "when there is at least one role" do
    let(:employments) do
      [
        build(:employment, organisation: "A school", started_on: Date.parse("2021-01-01"), ended_on: Date.parse("2021-02-01")),
        build(:employment, :current_role, job_title: "current role", organisation: "Some other place", started_on: Date.parse("2022-02-01")),
      ]
    end

    it "allows jobseekers to delete employment history" do
      click_on "Delete Teacher"

      expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :employment_history), ignore_query: true)
      expect(page).to have_content(I18n.t("jobseekers.job_applications.employments.destroy.success"))
      expect(page).not_to have_content("Teacher")
    end

    it "allows jobseekers to edit employment history" do
      click_on "Change Teacher"

      fill_in "School or other organisation", with: ""
      validates_step_complete(button: I18n.t("buttons.save_employment"))

      fill_in "School or other organisation", with: "A different school"
      click_on I18n.t("buttons.save_employment")

      expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :employment_history), ignore_query: true)
      expect(page).not_to have_content("A school")
      expect(page).to have_content("A different school")
    end
  end
end
