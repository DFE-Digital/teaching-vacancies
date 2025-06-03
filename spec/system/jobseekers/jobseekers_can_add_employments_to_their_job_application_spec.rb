require "rails_helper"

RSpec.describe "Jobseekers can add employments and breaks to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let!(:job_application) { create(:native_job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  after { logout }

  it "allows jobseekers to add a current role" do
    visit jobseekers_job_application_build_path(job_application, :employment_history)

    click_on I18n.t("buttons.add_work_history")
    expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_job_application_build_path(job_application, :employment_history))
    validates_step_complete(button: I18n.t("buttons.save_employment"))

    fill_in_current_role(form: "jobseekers_job_application_details_employment_form")

    click_on I18n.t("buttons.save_employment")

    expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :employment_history))
    expect(page).to have_content("The Best Teacher")
    expect(page).to have_content("English KS1")
  end

  it "allows jobseekers to add employment history" do
    visit jobseekers_job_application_build_path(job_application, :employment_history)

    click_on I18n.t("buttons.add_work_history")
    validates_step_complete(button: I18n.t("buttons.save_employment"))

    fill_in_employment_history

    click_on I18n.t("buttons.save_employment")

    expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :employment_history))
    expect(page).to have_content("The Best Teacher")
    expect(page).to have_content(Date.new(2020, 7, 1).to_formatted_s(:month_year))
  end

  context "with an employmeent history" do
    before do
      build(:employment, reason_for_leaving: nil, job_application: job_application, job_title: "Oldest job",
                         started_on: Date.new(2015, 7, 1), ended_on: Date.new(2019, 7, 1)).save!(validate: false)
      create(:employment, job_application: job_application, job_title: "Old job", started_on: Date.new(2019, 7, 1), ended_on: Date.new(2020, 7, 1))
      create(:employment, :current_role, job_application: job_application, job_title: "The Best Teacher", started_on: Date.new(2020, 7, 1))

      visit jobseekers_job_application_build_path(job_application, :employment_history)
    end

    it "displays employment history from newest to oldest job" do
      expect(all(".govuk-summary-card__title").map(&:text)).to eq ["The Best Teacher", "Old job", "Oldest job"]
    end

    it "shows the record with an error, and prevents saving until fixed" do
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
    before do
      create(:employment, :job, job_application: job_application, started_on: Date.parse("2021-01-01"), ended_on: Date.parse("2021-02-01"))
      create(:employment, :job, :current_role, job_application: job_application, started_on: Date.parse("2021-06-01"))
    end

    it "allows jobseekers to add, change and delete gaps in employment with prefilled start and end date" do
      visit jobseekers_job_application_build_path(job_application, :employment_history)
      expect(page).to have_content "You have a gap in your work history from February 2021 to June 2021 (4 months)"
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

      click_on "Change Gap in work history 2021-02-01 to 2021-06-01"

      fill_in "Enter reasons for gap in work history", with: ""
      click_on I18n.t("buttons.continue")

      expect(page).to have_content("There is a problem")

      fill_in "Enter reasons for gap in work history", with: "Looking after my needy turtle"
      click_on I18n.t("buttons.continue")

      expect(page).to have_content("Looking after my needy turtle")

      click_on "Delete Gap in work history 2021-02-01 to 2021-06-01"
      click_on I18n.t("buttons.confirm_destroy")

      expect(page).not_to have_content("Looking after my needy turtle")
    end
  end

  context "when there is at least one role" do
    let!(:employment) { create(:employment, organisation: "A school", job_application: job_application, started_on: Date.parse("2021-01-01"), ended_on: Date.parse("2021-02-01")) }
    let!(:employment2) { create(:employment, :current_role, job_title: "current role", organisation: "Some other place", job_application: job_application, started_on: Date.parse("2022-02-01")) }

    it "allows jobseekers to delete employment history" do
      visit jobseekers_job_application_build_path(job_application, :employment_history)

      click_on "Delete Teacher"

      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :employment_history))
      expect(page).to have_content(I18n.t("jobseekers.job_applications.employments.destroy.success"))
      expect(page).not_to have_content("Teacher")
    end

    it "allows jobseekers to edit employment history" do
      visit jobseekers_job_application_build_path(job_application, :employment_history)

      click_on "Change Teacher"

      fill_in "School or other organisation", with: ""
      validates_step_complete(button: I18n.t("buttons.save_employment"))

      fill_in "School or other organisation", with: "A different school"
      click_on I18n.t("buttons.save_employment")

      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :employment_history))
      expect(page).not_to have_content("A school")
      expect(page).to have_content("A different school")
    end

    context "when there are gaps in work history" do
      it "will not allow the user to complete the employment history section until the gaps are explained" do
        visit jobseekers_job_application_build_path(job_application, :employment_history)
        expect(page).to have_content "You have a gap in your work history from February 2021 to February 2022 (12 months)"
        choose("Yes, I've completed this section")
        click_button("Save and continue")

        expect(page).to have_content("You have a gap in your work history (12 months).")
        expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :employment_history))

        click_on I18n.t("buttons.add_reason_for_break")

        expect(page).to have_field("jobseekers_break_form_started_on_1i", with: "2021")
        expect(page).to have_field("jobseekers_break_form_started_on_2i", with: "2")
        expect(page).to have_field("jobseekers_break_form_ended_on_1i", with: "2022")
        expect(page).to have_field("jobseekers_break_form_ended_on_2i", with: "2")

        fill_in "Enter reasons for gap in work history", with: "Travelling around the world"
        click_on I18n.t("buttons.continue")

        choose("Yes, I've completed this section")
        click_button("Save and continue")

        expect(page).not_to have_content("You must provide your full work history, including the reason for any gaps in employment")
        expect(page).not_to have_current_path(jobseekers_job_application_build_path(job_application, :employment_history))
      end
    end
  end
end
