require "rails_helper"

RSpec.describe "Jobseekers can complete a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit job_path(vacancy)
    # There are 2 apply buttons here with identical text - use the one at the top of the form
    within ".banner-buttons" do
      click_on("Apply for this job")
    end
  end

  after { logout }

  context "when job application is a using the native job application" do
    let(:vacancy) { create(:vacancy, job_roles: ["teacher"], organisations: [organisation]) }

    before do
      #  wait for page load - this only works for a quick apply job, not an uploaded one
      within "main" do
        find("form.button_to")
      end
    end

    it "passes a11y", :a11y do
      expect(page).to be_axe_clean
    end

    it "allows jobseekers to complete an application and go to review page", :a11y do
      click_button "Start application"
      click_on(I18n.t("jobseekers.job_applications.build.personal_details.heading"))
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

      expect(page).to be_axe_clean

      validates_step_complete
      fill_in_personal_statement
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_css("#personal_statement", text: I18n.t("shared.status_tags.complete"))

      click_on(I18n.t("jobseekers.job_applications.build.referees.heading"))

      click_on I18n.t("buttons.add_referee")
      click_on I18n.t("buttons.save_reference")
      expect(page).to have_content("There is a problem")
      fill_in_referee
      click_on I18n.t("buttons.save_reference")
      click_on I18n.t("buttons.add_another_reference")
      fill_in_referee
      click_on I18n.t("buttons.save_reference")
      choose I18n.t("helpers.label.jobseekers_job_application_referees_form.referees_section_completed_options.true")
      choose "Yes"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_css("#referees", text: I18n.t("shared.status_tags.complete"))

      click_on(I18n.t("jobseekers.job_applications.build.equal_opportunities.heading"))

      #  https://github.com/alphagov/govuk-frontend/issues/979
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"

      validates_step_complete
      fill_in_equal_opportunities
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_css("#equal_opportunities", text: I18n.t("shared.status_tags.complete"))

      click_on(I18n.t("jobseekers.job_applications.build.ask_for_support.heading"))

      #  https://github.com/alphagov/govuk-frontend/issues/979
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"

      validates_step_complete
      fill_in_ask_for_support
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_css("#ask_for_support", text: I18n.t("shared.status_tags.complete"))

      click_on(I18n.t("jobseekers.job_applications.build.declarations.heading"))

      #  https://github.com/alphagov/govuk-frontend/issues/979
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"

      validates_step_complete
      fill_in_declarations
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_css("#declarations", text: I18n.t("shared.status_tags.complete"))
      click_on "Review application"

      # wait for page load
      find(".govuk-list.review-component__sections")
      expect(page).to have_current_path(jobseekers_job_application_review_path(JobApplication.last), ignore_query: true)
    end
  end

  context "when job application has a custom uploaded job application" do
    let(:vacancy) { create(:vacancy, :with_uploaded_application_form, job_roles: ["teacher"], organisations: [organisation]) }

    it "errors on the review button" do
      click_button "Review application"
      within(".govuk-error-summary__body") do
        expect(page).to have_link("Complete your personal details")
      end
    end

    it "allows jobseekers to complete an application and go to review page" do
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
      fill_in "What is your teacher reference number? (optional)", with: "7777777"
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
      allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(instance_double(Publishers::DocumentVirusCheck, safe?: true))
      attach_file(
        "jobseekers_uploaded_job_application_upload_application_form_form[application_form]",
        Rails.root.join("spec/fixtures/files/blank_baptism_cert.pdf"),
      )
      choose I18n.t("helpers.label.jobseekers_uploaded_job_application_upload_application_form_form.upload_application_form_section_completed_options.true")
      click_on I18n.t("buttons.save_and_continue")

      click_button "Review application"
      expect(page).to have_current_path(jobseekers_job_application_review_path(vacancy.job_applications.first), ignore_query: true)
    end
  end
end
