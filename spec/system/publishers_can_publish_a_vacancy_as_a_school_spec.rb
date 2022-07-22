require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school, :all_through, name: "Salisbury School") }

  before { login_publisher(publisher: publisher, organisation: school) }

  scenario "Visiting the school page" do
    visit organisation_path

    expect(page).to have_content("Salisbury School")

    click_on I18n.t("buttons.create_job")

    expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 9))
  end

  context "creating a new vacancy" do
    let(:job_roles) { %i[teacher send_responsible] }
    let(:vacancy) do
      VacancyPresenter.new(build(:vacancy,
                                 job_roles: job_roles,
                                 phase: "multiple_phases",
                                 working_patterns: Vacancy.working_patterns.keys,
                                 publish_on: Date.current))
    end
    let(:created_vacancy) { Vacancy.last }

    scenario "follows the flow" do
      visit organisation_path
      click_on I18n.t("buttons.create_job")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role))

      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role))

      fill_in_job_role_form_fields(vacancy)
      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role_details))

      fill_in_ect_status_form_fields(vacancy)
      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :education_phases))

      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :education_phases))

      fill_in_education_phases_form_fields(vacancy)
      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_details))

      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_details))

      fill_in_job_details_form_fields(vacancy)
      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :working_patterns))

      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :working_patterns))

      fill_in_working_patterns_form_fields(vacancy)
      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

      fill_in_pay_package_form_fields(vacancy)
      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

      fill_in_important_dates_fields(vacancy)
      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

      fill_in_applying_for_the_job_form_fields(vacancy, local_authority_vacancy: false)
      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job_details))

      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_application_forms_path(created_vacancy.id))

      fill_in_applying_for_the_job_details_form_fields(vacancy, local_authority_vacancy: false)
      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_documents_path(created_vacancy.id))

      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_summary))

      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_summary))

      fill_in_job_summary_form_fields(vacancy)
      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
      verify_all_vacancy_details(created_vacancy)

      click_on I18n.t("buttons.submit_job_listing")
      expect(current_path).to eq(organisation_job_summary_path(created_vacancy.id))
    end

    scenario "redirects to the vacancy review page when submitted successfully" do
      visit organisation_path
      click_on I18n.t("buttons.create_job")
      click_on "Continue"

      fill_in_job_role_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_ect_status_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_education_phases_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_job_details_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_working_patterns_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_pay_package_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_important_dates_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_applying_for_the_job_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_applying_for_the_job_details_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      click_on I18n.t("buttons.continue")

      fill_in_job_summary_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      expect(page).to have_content(I18n.t("jobs.current_step", step: 9, total: 9))
      within("h2.govuk-heading-l") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
      end
      verify_all_vacancy_details(created_vacancy)
    end

    describe "#publish" do
      scenario "cannot be published unless the details are valid" do
        yesterday_date = Time.zone.yesterday
        vacancy = create(:vacancy, :draft, organisations: [school], publish_on: Time.zone.tomorrow, job_roles: %w[teacher], phase: "multiple_phases")
        vacancy.assign_attributes expires_at: yesterday_date
        vacancy.save(validate: false)

        visit organisation_job_path(vacancy.id)
        visit organisation_job_build_path(vacancy.id, :important_dates)

        expect(page).to have_content(I18n.t("jobs.current_step", step: 5, total: 9))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("publishers.vacancies.steps.important_dates"))
        end

        expect(find_field("publishers_job_listing_important_dates_form[expires_at(3i)]").value).to eq(yesterday_date.day.to_s)
        expect(find_field("publishers_job_listing_important_dates_form[expires_at(2i)]").value).to eq(yesterday_date.month.to_s)
        expect(find_field("publishers_job_listing_important_dates_form[expires_at(1i)]").value).to eq(yesterday_date.year.to_s)

        click_on I18n.t("buttons.update_job")

        within(".govuk-error-summary") do
          expect(page).to have_content("There is a problem")
        end

        within_row_for(element: "legend",
                       text: strip_tags(I18n.t("helpers.legend.publishers_job_listing_important_dates_form.expires_at"))) do
          expect(page).to have_content(I18n.t("important_dates_errors.expires_at.after"))
        end

        expiry_date = Date.current + 1.week

        fill_in "publishers_job_listing_important_dates_form[expires_at(3i)]", with: expiry_date.day
        fill_in "publishers_job_listing_important_dates_form[expires_at(2i)]", with: expiry_date.month
        fill_in "publishers_job_listing_important_dates_form[expires_at(1i)]", with: expiry_date.year
        choose "9am", name: "publishers_job_listing_important_dates_form[expiry_time]"

        click_on I18n.t("buttons.update_job")

        click_on I18n.t("buttons.submit_job_listing")
        expect(current_path).to eq(organisation_job_summary_path(vacancy.id))
      end

      scenario "only shows errors for a field once" do
        visit organisation_path
        click_on "Create a job listing"
        click_on "Continue"

        choose "Teacher"
        click_on "Continue"

        fill_in_ect_status_form_fields(vacancy)
        click_on "Continue"

        choose "Secondary"
        click_on "Continue"

        fill_in "Job title", with: "test vacancy"
        choose "Permanent"
        click_on "Continue"

        click_on "Cancel and return to manage jobs"
        click_on "test vacancy"
        click_on "Confirm and submit job"

        # Top level errors
        errors = page.all(".govuk-error-summary__list a").map(&:text)
        expect(errors).to match_array(errors.uniq)

        # Inline errors
        errors = page.all(".govuk-summary-list__row a").map(&:text)
        expect(errors).to match_array(errors.uniq)
      end

      scenario "can be published at a later date" do
        vacancy = create(:vacancy, :draft, organisations: [school], publish_on: Time.zone.tomorrow, job_roles: %w[teacher], phase: "multiple_phases")

        visit organisation_job_review_path(vacancy.id)
        click_on "Confirm and submit job"

        expect(page).to have_content("Your job listing will be posted on #{format_date(vacancy.publish_on)}.")
        visit organisation_job_path(vacancy.id)
        expect(page).to have_content(format_date(vacancy.publish_on).to_s)
      end

      scenario "displays the expiration date and time on the confirmation page" do
        vacancy = create(:vacancy, :draft, organisations: [school], expires_at: 5.days.from_now.change(hour: 9, minute: 0), job_roles: %w[teacher], phase: "multiple_phases")
        visit organisation_job_review_path(vacancy.id)
        click_on I18n.t("buttons.submit_job_listing")

        expect(page).to have_content(I18n.t("publishers.vacancies.summary.date_expires", application_deadline: format_time_to_datetime_at(vacancy.expires_at)))
      end

      scenario "a published vacancy cannot be republished" do
        vacancy = create(:vacancy, :draft, organisations: [school], publish_on: Time.zone.tomorrow, job_roles: %w[teacher], phase: "multiple_phases")

        visit organisation_job_review_path(vacancy.id)
        click_on "Confirm and submit job"
        expect(page).to have_content("The job listing has been completed")

        visit organisation_job_publish_path(vacancy.id)

        expect(page).to have_content(I18n.t("messages.jobs.already_published"))
      end

      scenario "a published vacancy cannot be edited" do
        vacancy = create(:vacancy, :published, organisations: [school])

        visit organisation_job_review_path(vacancy.id)
        expect(page.current_path).to eq(organisation_job_path(vacancy.id))
        expect(page).to have_content(I18n.t("messages.jobs.already_published"))
      end

      context "adds a job to update the Google index in the queue" do
        scenario "if the vacancy is published immediately" do
          vacancy = create(:vacancy, :draft, organisations: [school], publish_on: Date.current, job_roles: %w[teacher], phase: "multiple_phases")

          expect_any_instance_of(Publishers::Vacancies::BaseController)
            .to receive(:update_google_index).with(vacancy)

          visit organisation_job_review_path(vacancy.id)
          click_on I18n.t("buttons.submit_job_listing")
        end
      end
    end
  end
end
