require "rails_helper"

RSpec.describe "Jobseekers can complete a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, job_roles: ["teacher"], organisations: [organisation]) }

  before { login_as(jobseeker, scope: :jobseeker) }

  after { logout }

  context "when job application is a using the native job application" do
    it "allows jobseekers to complete an application and go to review page" do
      visit job_path(vacancy)
      all("button", text: "Apply for this job").last.click
      click_button "Start application"
      click_on(I18n.t("jobseekers.job_applications.build.personal_details.heading"))
      expect(page).to have_field("Email address", with: jobseeker.email)
      validates_step_complete
      fill_in_personal_details
      click_on I18n.t("buttons.save_and_continue")

      click_on(I18n.t("jobseekers.job_applications.build.professional_status.heading"))
      validates_step_complete
      fill_in_professional_status
      click_on I18n.t("buttons.save_and_continue")

      click_on(I18n.t("jobseekers.job_applications.build.qualifications.heading"))
      validates_step_complete
      choose I18n.t("helpers.label.jobseekers_job_application_qualifications_form.qualifications_section_completed_options.true")
      click_on I18n.t("buttons.save_and_continue")
      expect(page).not_to have_content("There is a problem")

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

      click_on(I18n.t("jobseekers.job_applications.build.training_and_cpds.heading"))
      expect(page).to have_content("No training or CPD specified")
      validates_step_complete
      click_on "Add training"
      click_on "Save and continue"
      expect(page).to have_content("There is a problem")
      fill_in_training_and_cpds
      click_on "Save and continue"
      choose "Yes, I've completed this section"
      click_on "Save and continue"

      click_on(I18n.t("jobseekers.job_applications.build.professional_body_memberships.list_heading"))
      expect(page).to have_content("No memberships")
      validates_step_complete
      click_on "Add membership"
      click_on "Save and continue"
      expect(page).to have_content("There is a problem")
      fill_in_professional_body_membership
      click_on "Save and continue"
      choose "Yes, I've completed this section"
      click_on "Save and continue"

      click_on(I18n.t("jobseekers.job_applications.build.employment_history.heading"))
      validates_step_complete
      click_on I18n.t("buttons.add_work_history")
      click_on I18n.t("buttons.save_employment")
      expect(page).to have_content("There is a problem")
      fill_in_employment_history
      click_on I18n.t("buttons.save_employment")
      click_on I18n.t("buttons.add_reason_for_break")
      fill_in_break_in_employment(end_year: Date.today.year.to_s, end_month: Date.today.month.to_s.rjust(2, "0"))
      click_on I18n.t("buttons.continue")
      choose I18n.t("helpers.label.jobseekers_job_application_employment_history_form.employment_history_section_completed_options.true")
      click_on I18n.t("buttons.save_and_continue")

      click_on(I18n.t("jobseekers.job_applications.build.personal_statement.heading"))
      validates_step_complete
      fill_in_personal_statement
      click_on I18n.t("buttons.save_and_continue")
<<<<<<< HEAD
  
      click_on(I18n.t("jobseekers.job_applications.build.referees.heading"))
  
=======

      click_on(I18n.t("jobseekers.job_applications.build.references.heading"))

>>>>>>> 542a14904 (Linting)
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

      click_on(I18n.t("jobseekers.job_applications.build.equal_opportunities.heading"))
      validates_step_complete
      fill_in_equal_opportunities
      click_on I18n.t("buttons.save_and_continue")

      click_on(I18n.t("jobseekers.job_applications.build.ask_for_support.heading"))
      validates_step_complete
      fill_in_ask_for_support
      click_on I18n.t("buttons.save_and_continue")

      click_on(I18n.t("jobseekers.job_applications.build.declarations.heading"))
      validates_step_complete
      fill_in_declarations
      click_on I18n.t("buttons.save_and_continue")
      click_on "Review application"

      expect(current_path).to eq(jobseekers_job_application_review_path(JobApplication.last))
    end
  end

  context "when job application has a custom uploaded job application" do
    before do
      vacancy.receive_applications = "uploaded_form"
      vacancy.save!
    end

    it "allows jobseekers to complete an application and go to review page" do
      visit job_path(vacancy)
      all("button", text: "Apply for this job").last.click
      click_button "Review application"
      click_link(I18n.t("jobseekers.job_applications.build.personal_details.heading"))
      validates_step_complete
      choose I18n.t("helpers.label.jobseekers_job_application_personal_details_form.personal_details_section_completed_options.false")
      click_on I18n.t("buttons.save_and_continue")
      expect(page).not_to have_content("There is a problem")
      expect(page).to have_css("#personal_details .govuk-task-list__status .govuk-tag", text: "Incomplete")
      click_link(I18n.t("jobseekers.job_applications.build.personal_details.heading"))
      choose I18n.t("helpers.label.jobseekers_job_application_personal_details_form.personal_details_section_completed_options.true")
      click_on I18n.t("buttons.save_and_continue")
      within(".govuk-error-summary__body") do
        expect(page).to have_link("Enter your first name")
        expect(page).to have_link("Enter your last name")
        expect(page).to have_link("Enter your phone number")
        expect(page).to have_link("Select no if you have the right to work in the UK")
      end
      fill_in "First name", with: "John"
      fill_in "Last name", with: "Frusciante"
      fill_in "Phone number", with: "01234 123456"
      fill_in "Email address", with: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)
      fill_in "What is your teacher reference number (TRN)?", with: "7777777"
      choose "No, I already have the right to work in the UK"
      choose I18n.t("helpers.label.jobseekers_job_application_personal_details_form.personal_details_section_completed_options.true")
      click_on I18n.t("buttons.save_and_continue")

      click_link "Upload application form"
      validates_step_complete
      choose I18n.t("helpers.label.jobseekers_uploaded_job_application_upload_application_form_form.upload_application_form_section_completed_options.false")
      click_on I18n.t("buttons.save_and_continue")
      expect(page).not_to have_content("There is a problem")
      expect(page).to have_css("#upload_application_form .govuk-task-list__status .govuk-tag", text: "Incomplete")
      click_link "Upload application form"
      choose I18n.t("helpers.label.jobseekers_uploaded_job_application_upload_application_form_form.upload_application_form_section_completed_options.true")
      click_on I18n.t("buttons.save_and_continue")
      within(".govuk-error-summary__body") do
        expect(page).to have_link("Select the completed job application form")
      end
      allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))
      attach_file(
        "jobseekers_uploaded_job_application_upload_application_form_form[application_form]",
        Rails.root.join("spec/fixtures/files/blank_baptism_cert.pdf"),
      )
      choose I18n.t("helpers.label.jobseekers_uploaded_job_application_upload_application_form_form.upload_application_form_section_completed_options.true")
      click_on I18n.t("buttons.save_and_continue")

      click_button "Review application"
      expect(current_path).to eq(jobseekers_job_application_review_path(vacancy.job_applications.first))
    end
  end
end
