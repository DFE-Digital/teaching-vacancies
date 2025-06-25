require "rails_helper"

RSpec.describe "Jobseekers can complete a job application" do
  let(:jobseeker) { create(:jobseeker, jobseeker_profile: jobseeker_profile) }
  let(:jobseeker_profile) { create(:jobseeker_profile, :with_trn) }
  let(:vacancy) { create(:vacancy, job_roles: ["teacher"], organisations: [organisation]) }
  let(:organisation) { create(:school) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  after { logout }

  it "allows jobseekers to complete an application and go to review page" do
    visit jobseekers_job_application_build_path(job_application, :personal_details)
    expect(page).to have_content(I18n.t("jobseekers.job_applications.build.personal_details.heading"))
    expect(page).to have_field("Email address", with: job_application.email_address)
    validates_step_complete
    fill_in_personal_details
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#personal_details", text: I18n.t("shared.status_tags.complete"))

    click_on(I18n.t("jobseekers.job_applications.build.professional_status.heading"))
    validates_step_complete
    fill_in_professional_status
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#professional_status", text: I18n.t("shared.status_tags.complete"))

    click_on(I18n.t("jobseekers.job_applications.build.qualifications.heading"))
    validates_step_complete
    choose I18n.t("helpers.label.jobseekers_job_application_qualifications_form.qualifications_section_completed_options.true")
    click_on I18n.t("buttons.save_and_continue")

    click_on I18n.t("jobseekers.job_applications.build.qualifications.heading")
    click_on I18n.t("buttons.add_qualification")
    validates_step_complete(button: I18n.t("buttons.continue"))
    select_qualification_category("Undergraduate degree")
    expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.undergraduate"))
    validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
    fill_in_undergraduate_degree
    click_on I18n.t("buttons.save_qualification.one")
    choose "Yes, I've completed this section"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#qualifications", text: I18n.t("shared.status_tags.complete"))

    click_on(I18n.t("jobseekers.job_applications.build.training_and_cpds.heading"))
    expect(page).to have_content("No training or CPD specified")
    validates_step_complete
    click_on "Add training"
    fill_in_training_and_cpds
    click_on "Save and continue"
    choose "Yes, I've completed this section"
    click_on "Save and continue"
    expect(page).to have_css("#training_and_cpds", text: I18n.t("shared.status_tags.complete"))

    click_on(I18n.t("jobseekers.job_applications.build.professional_body_memberships.list_heading"))
    expect(page).to have_content("No memberships")
    validates_step_complete
    click_on "Add membership"
    fill_in_professional_body_membership
    click_on "Save and continue"
    choose "Yes, I've completed this section"
    click_on "Save and continue"
    expect(page).to have_css("#professional_body_memberships", text: I18n.t("shared.status_tags.complete"))

    click_on(I18n.t("jobseekers.job_applications.build.employment_history.heading"))
    validates_step_complete
    click_on I18n.t("buttons.add_work_history")
    fill_in_employment_history
    click_on I18n.t("buttons.save_employment")
    click_on I18n.t("buttons.add_reason_for_break")
    fill_in_break_in_employment(end_year: Date.today.year.to_s, end_month: Date.today.month.to_s.rjust(2, "0"))
    click_on I18n.t("buttons.continue")
    choose I18n.t("helpers.label.jobseekers_job_application_employment_history_form.employment_history_section_completed_options.true")
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#employment_history", text: I18n.t("shared.status_tags.complete"))

    click_on(I18n.t("jobseekers.job_applications.build.personal_statement.heading"))
    validates_step_complete
    fill_in_personal_statement
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#personal_statement", text: I18n.t("shared.status_tags.complete"))

    click_on(I18n.t("jobseekers.job_applications.build.referees.heading"))

    click_on I18n.t("buttons.add_reference")
    click_on I18n.t("buttons.save_reference")
    expect(page).to have_content("There is a problem")
    fill_in_referee
    click_on I18n.t("buttons.save_reference")
    click_on I18n.t("buttons.add_another_reference")
    fill_in_referee
    click_on I18n.t("buttons.save_reference")
    choose I18n.t("helpers.label.jobseekers_job_application_referees_form.referees_section_completed_options.true")
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#referees", text: I18n.t("shared.status_tags.complete"))

    click_on(I18n.t("jobseekers.job_applications.build.equal_opportunities.heading"))
    validates_step_complete
    fill_in_equal_opportunities
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#equal_opportunities", text: I18n.t("shared.status_tags.complete"))

    click_on(I18n.t("jobseekers.job_applications.build.ask_for_support.heading"))
    validates_step_complete
    fill_in_ask_for_support
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#ask_for_support", text: I18n.t("shared.status_tags.complete"))

    click_on(I18n.t("jobseekers.job_applications.build.declarations.heading"))
    validates_step_complete
    fill_in_declarations
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#declarations", text: I18n.t("shared.status_tags.complete"))
    click_on "Review application"

    expect(current_path).to eq(jobseekers_job_application_review_path(job_application))
  end
end
