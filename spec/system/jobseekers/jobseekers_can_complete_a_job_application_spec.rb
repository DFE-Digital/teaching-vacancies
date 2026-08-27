require "rails_helper"

RSpec.describe "Jobseekers can complete a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    use_ab_test jobseeker, :trn_on_apply, ab_test

    visit job_path(vacancy)
  end

  after { logout }

  context "with a TVS vacancy" do
    before do
      # There are 2 apply buttons here with identical text - use the one at the top of the form
      within ".banner-buttons" do
        click_on("Apply for this job")
      end
    end

    context "with a native job application" do
      let(:vacancy) { create(:vacancy, :live, job_roles: ["teacher"], organisations: [organisation]) }

      context "without TRN ab test" do
        let(:ab_test) { "apply" }
        let(:job_application) do
          create(:job_application, :status_draft, :with_personal_details, :with_professional_status,
                 completed_steps: %w[personal_details professional_status qualifications training_and_cpds professional_body_memberships employment_history],
                 jobseeker: jobseeker)
        end

        before do
          #  wait for page load - this only works for a quick apply job, not an uploaded one
          within "main" do
            find("form.button_to")
          end
        end

        describe "accessibility", :a11y do
          it "passes a11y" do
            expect(page).to be_axe_clean
          end

          it "has an accessible starting page" do
            click_button "Start application"
            expect(page).to be_axe_clean
          end

          it "has an accessible personal statement" do
            visit jobseekers_job_application_apply_path(job_application)

            click_on(I18n.t("jobseekers.job_applications.build.personal_statement.heading"))

            expect(page).to be_axe_clean
          end

          it "has an accessible equal opportunities section" do
            visit jobseekers_job_application_apply_path(job_application)

            click_on(I18n.t("jobseekers.job_applications.build.equal_opportunities.heading"))

            #  https://github.com/alphagov/govuk-frontend/issues/979
            expect(page).to be_axe_clean.skipping "aria-allowed-attr"
          end

          it "has an accessible support section" do
            visit jobseekers_job_application_apply_path(job_application)

            click_on(I18n.t("jobseekers.job_applications.build.ask_for_support.heading"))

            #  https://github.com/alphagov/govuk-frontend/issues/979
            expect(page).to be_axe_clean.skipping "aria-allowed-attr"
          end

          it "has an accessible declarations section" do
            visit jobseekers_job_application_apply_path(job_application)

            click_on(I18n.t("jobseekers.job_applications.build.declarations.heading"))

            #  https://github.com/alphagov/govuk-frontend/issues/979
            expect(page).to be_axe_clean.skipping "aria-allowed-attr"
          end
        end

        it "allows jobseekers to complete an application and go to review page" do
          visit jobseekers_job_application_apply_path(job_application)

          click_on(I18n.t("jobseekers.job_applications.build.personal_statement.heading"))
          fill_personal_statement_referees

          click_on(I18n.t("jobseekers.job_applications.build.equal_opportunities.heading"))
          fill_in_equal_opportunities_section

          click_on(I18n.t("jobseekers.job_applications.build.ask_for_support.heading"))
          fill_in_ask_for_support_section

          click_on(I18n.t("jobseekers.job_applications.build.declarations.heading"))

          validates_step_complete
          fill_in_declarations
          click_on I18n.t("buttons.save_and_continue")
          expect(page).to have_css("#declarations", text: I18n.t("shared.status_tags.complete"))
          click_on "Review and submit application"

          # wait for page load
          find(".govuk-list.review-component__sections")
          expect(page).to have_current_path(jobseekers_job_application_review_path(job_application), ignore_query: true)
        end
      end

      context "when asking for a TRN" do
        let(:ab_test) { "trn" }

        scenario "with a TRN" do
          expect(page).to have_content("What is your teacher reference number")

          # don't have to supply anything
          click_on "Continue"
          click_on "Start application"
          expect(page).to have_content(vacancy.job_title)
        end

        scenario "without a TRN" do
          expect(page).to have_content("What is your teacher reference number")

          click_on "Skip"
          click_on "Start application"
          expect(page).to have_content(vacancy.job_title)
        end
      end
    end

    context "when job application has a custom uploaded job application" do
      let(:vacancy) { create(:vacancy, :with_uploaded_application_form, job_roles: ["teacher"], organisations: [organisation]) }

      context "without TRN ab test" do
        let(:ab_test) { "apply" }

        it "errors on the review button" do
          click_button "Review and submit application"
          within(".govuk-error-summary__body") do
            expect(page).to have_link("Complete your personal details")
          end
        end

        it "allows jobseekers to complete an application and go to review page" do
          click_link(I18n.t("jobseekers.job_applications.build.personal_details.heading"))
          validates_step_complete
          choose I18n.t("helpers.label.jobseekers_uploaded_job_application_personal_details_form.personal_details_section_completed_options.false")
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
          attach_file(
            "jobseekers_uploaded_job_application_upload_application_form_form[application_form]",
            Rails.root.join("spec/fixtures/files/blank_baptism_cert.pdf"),
          )
          choose I18n.t("helpers.label.jobseekers_uploaded_job_application_upload_application_form_form.upload_application_form_section_completed_options.true")
          click_on I18n.t("buttons.save_and_continue")

          click_button "Review and submit application"
          expect(page).to have_current_path(jobseekers_job_application_review_path(vacancy.job_applications.first), ignore_query: true)
        end
      end

      context "when asking for a TRN" do
        let(:ab_test) { "trn" }

        scenario "with a TRN" do
          expect(page).to have_content("What is your teacher reference number")
          fill_in "job-application-teacher-reference-number-field", with: Faker::Number.number(digits: 7)

          click_on "Continue"
          expect(page).to have_content(vacancy.job_title)
        end

        scenario "without a TRN" do
          expect(page).to have_content("What is your teacher reference number")

          click_on "Skip"
          expect(page).to have_content(vacancy.job_title)
        end
      end
    end
  end

  context "when vacancy is via a website" do
    let(:vacancy) { create(:vacancy, :apply_via_website, application_link: "www.google.co.uk", job_roles: ["teacher"], organisations: [organisation]) }

    context "without TRN ab test" do
      let(:ab_test) { "apply" }

      it "allows the user to apply" do
        expect(page).to have_link(href: vacancy.application_link)
      end
    end

    context "when asking for a TRN" do
      let(:ab_test) { "trn" }

      scenario "with a TRN" do
        expect(page).to have_no_link(href: vacancy.application_link)
        find("a.govuk-button").click
        expect(page).to have_content("What is your teacher reference number")
        fill_in "job-application-teacher-reference-number-field", with: Faker::Number.number(digits: 7)
        click_on "Continue"
        expect(page).to have_current_path(vacancy.application_link)
      end

      scenario "without a TRN" do
        find("a.govuk-button").click
        expect(page).to have_content("What is your teacher reference number")
        click_on "Skip"
        expect(page).to have_current_path(vacancy.application_link)
      end
    end
  end

  def fill_in_ask_for_support_section
    validates_step_complete
    fill_in_ask_for_support
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#ask_for_support", text: I18n.t("shared.status_tags.complete"))
  end

  def fill_in_equal_opportunities_section
    validates_step_complete
    fill_in_equal_opportunities
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("#equal_opportunities", text: I18n.t("shared.status_tags.complete"))
  end

  def fill_personal_statement_referees
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
  end
end
