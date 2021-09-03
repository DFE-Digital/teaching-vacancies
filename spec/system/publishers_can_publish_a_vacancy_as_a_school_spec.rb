require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school, name: "Salisbury School") }

  before { login_publisher(publisher: publisher, organisation: school) }

  scenario "Visiting the school page" do
    visit organisation_path

    expect(page).to have_content("Salisbury School")
    expect(page).to have_content(/#{school.address}/)
    expect(page).to have_content(/#{school.town}/)

    click_on I18n.t("buttons.create_job")

    expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 9))
  end

  context "creating a new vacancy" do
    let(:job_roles) { %i[teacher send_responsible] }
    let(:vacancy) do
      VacancyPresenter.new(build(:vacancy,
                                 job_roles: job_roles,
                                 working_patterns: %w[full_time part_time],
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
      expect(current_path).to eq(organisation_job_documents_path(created_vacancy.id))

      click_on I18n.t("buttons.continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

      click_on I18n.t("buttons.continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

      fill_in_applying_for_the_job_form_fields(vacancy)
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

      fill_in_job_role_form_fields(vacancy)
      click_on I18n.t("buttons.continue")
      click_on I18n.t("buttons.continue")

      fill_in_job_details_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_working_patterns_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_pay_package_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_important_dates_fields(vacancy)
      click_on I18n.t("buttons.continue")

      click_on I18n.t("buttons.continue")

      fill_in_applying_for_the_job_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_job_summary_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      expect(page).to have_content(I18n.t("jobs.current_step", step: 9, total: 9))
      within("h2.govuk-heading-l") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
      end
      verify_all_vacancy_details(created_vacancy)
    end

    describe "#review" do
      context "redirects the user back to the last incomplete step" do
        scenario "redirects to pay package when that step has not been completed" do
          visit organisation_path
          click_on I18n.t("buttons.create_job")

          fill_in_job_role_form_fields(vacancy)
          click_on I18n.t("buttons.continue")
          click_on I18n.t("buttons.continue")

          fill_in_job_details_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          v = Vacancy.find_by(job_title: vacancy.job_title)
          visit edit_organisation_job_path(id: v.id)

          expect(page).to have_content(I18n.t("jobs.current_step", step: 4, total: 9))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("publishers.vacancies.steps.pay_package"))
          end
        end

        scenario "redirects to application details when that step has not been completed" do
          visit organisation_path
          click_on I18n.t("buttons.create_job")

          fill_in_job_role_form_fields(vacancy)
          click_on I18n.t("buttons.continue")
          click_on I18n.t("buttons.continue")

          fill_in_job_details_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          fill_in_working_patterns_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          fill_in_important_dates_fields(vacancy)
          click_on I18n.t("buttons.continue")

          click_on I18n.t("buttons.continue")

          v = Vacancy.find_by(job_title: vacancy.job_title)
          visit edit_organisation_job_path(id: v.id)

          expect(page).to have_content(I18n.t("jobs.current_step", step: 7, total: 9))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("publishers.vacancies.steps.applying_for_the_job"))
          end
        end

        scenario "redirects to job summary, when that step has not been completed" do
          visit organisation_path
          click_on I18n.t("buttons.create_job")

          fill_in_job_role_form_fields(vacancy)
          click_on I18n.t("buttons.continue")
          click_on I18n.t("buttons.continue")

          fill_in_job_details_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          fill_in_working_patterns_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          fill_in_important_dates_fields(vacancy)
          click_on I18n.t("buttons.continue")

          click_on I18n.t("buttons.continue")

          fill_in_applying_for_the_job_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          v = Vacancy.find_by(job_title: vacancy.job_title)
          visit edit_organisation_job_path(id: v.id)

          expect(page).to have_content(I18n.t("jobs.current_step", step: 8, total: 9))
          within("h2.govuk-heading-l") do
            expect(page).to have_content(I18n.t("publishers.vacancies.steps.job_summary"))
          end
        end
      end

      scenario "is not available for published vacancies" do
        vacancy = create(:vacancy, :published)
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)

        expect(page).to have_current_path(organisation_job_path(vacancy.id))
      end

      context "when a start date has been given" do
        scenario "lists all the vacancy details correctly" do
          vacancy = create(:vacancy, :draft)
          vacancy.organisation_vacancies.create(organisation: school)

          vacancy = VacancyPresenter.new(vacancy)
          visit organisation_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))

          verify_all_vacancy_details(vacancy)
        end
      end

      context "when the start date is as soon as possible" do
        scenario "lists all the vacancy details correctly" do
          vacancy = create(:vacancy, :draft, :starts_asap)
          vacancy.organisation_vacancies.create(organisation: school)

          vacancy = VacancyPresenter.new(vacancy)
          visit organisation_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))

          verify_all_vacancy_details(vacancy)
        end
      end

      context "when the listing is full-time" do
        scenario "lists all the full-time vacancy details correctly" do
          vacancy = create(:vacancy, :draft, working_patterns: %w[full_time])
          vacancy.organisation_vacancies.create(organisation: school)

          vacancy = VacancyPresenter.new(vacancy)

          visit organisation_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))

          verify_all_vacancy_details(vacancy)
        end
      end

      context "when the listing is part-time" do
        scenario "lists all the part-time vacancy details correctly" do
          vacancy = create(:vacancy, :draft, working_patterns: %w[part_time])
          vacancy.organisation_vacancies.create(organisation: school)

          vacancy = VacancyPresenter.new(vacancy)

          visit organisation_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))

          verify_all_vacancy_details(vacancy)
        end
      end

      context "when the listing is both full- and part-time" do
        scenario "lists all the working pattern vacancy details correctly" do
          vacancy = create(:vacancy, :draft, working_patterns: %w[full_time part_time])
          vacancy.organisation_vacancies.create(organisation: school)

          vacancy = VacancyPresenter.new(vacancy)

          visit organisation_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))

          verify_all_vacancy_details(vacancy)
        end
      end

      context "edit job_details_details" do
        scenario "updates the vacancy details" do
          vacancy = create(:vacancy, :draft, job_roles: %w[teacher])
          vacancy.organisation_vacancies.create(organisation: school)
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t("publishers.vacancies.steps.job_details"))

          expect(page).to have_content(I18n.t("jobs.current_step", step: 2, total: 9))

          fill_in "publishers_job_listing_job_details_form[job_title]", with: "An edited job title"
          click_on I18n.t("buttons.update_job")

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
          expect(page).to have_content("An edited job title")
        end

        scenario "fails validation until values are set correctly" do
          vacancy = create(:vacancy, :draft, job_roles: %w[teacher])
          vacancy.organisation_vacancies.create(organisation: school)
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t("publishers.vacancies.steps.job_details"))

          fill_in "publishers_job_listing_job_details_form[job_title]", with: ""
          click_on I18n.t("buttons.update_job")

          expect(page).to have_content("Enter a job title")

          fill_in "publishers_job_listing_job_details_form[job_title]", with: "A new job title"
          click_on I18n.t("buttons.update_job")

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
          expect(page).to have_content("A new job title")
        end
      end

      context "editing the supporting_documents" do
        scenario "updates the vacancy details" do
          visit organisation_path
          click_on I18n.t("buttons.create_job")

          fill_in_job_role_form_fields(vacancy)
          click_on I18n.t("buttons.continue")
          click_on I18n.t("buttons.continue")

          fill_in_job_details_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          fill_in_working_patterns_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          fill_in_important_dates_fields(vacancy)
          click_on I18n.t("buttons.continue")

          click_on I18n.t("buttons.continue")

          fill_in_applying_for_the_job_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          fill_in_job_summary_form_fields(vacancy)
          click_on I18n.t("buttons.continue")

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))

          click_header_link(I18n.t("publishers.vacancies.steps.documents"))

          expect(page).to have_content(I18n.t("jobs.current_step", step: 6, total: 9))
          expect(page).to have_content(I18n.t("helpers.label.publishers_job_listing_documents_form.documents"))

          click_on I18n.t("buttons.update_job")

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
        end
      end

      context "editing applying_for_the_job" do
        scenario "fails validation until values are set correctly" do
          vacancy = create(:vacancy, :draft, job_roles: %w[teacher])
          vacancy.organisation_vacancies.create(organisation: school)
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t("publishers.vacancies.steps.applying_for_the_job"))

          expect(page).to have_content(I18n.t("jobs.current_step", step: 7, total: 9))

          fill_in "publishers_job_listing_applying_for_the_job_form[contact_email]", with: "not a valid email"
          click_on I18n.t("buttons.update_job")

          expect(page).to have_content("Enter an email address in the correct format, like name@example.com")

          fill_in "publishers_job_listing_applying_for_the_job_form[contact_email]", with: "a@valid.email"
          click_on I18n.t("buttons.update_job")

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
          expect(page).to have_content("a@valid.email")
        end

        scenario "updates the vacancy details" do
          vacancy = create(:vacancy, :draft, job_roles: %w[teacher])
          vacancy.organisation_vacancies.create(organisation: school)
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t("publishers.vacancies.steps.applying_for_the_job"))

          expect(page).to have_content(I18n.t("jobs.current_step", step: 7, total: 9))

          fill_in "publishers_job_listing_applying_for_the_job_form[contact_email]", with: "an@email.com"
          click_on I18n.t("buttons.update_job")

          expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
          expect(page).to have_content("an@email.com")
        end
      end

      scenario "redirects to the summary page when published" do
        vacancy = create(:vacancy, :draft, job_roles: %w[teacher])
        vacancy.organisation_vacancies.create(organisation: school)
        visit organisation_job_review_path(vacancy.id)
        click_on I18n.t("buttons.submit_job_listing")

        expect(current_path).to eq(organisation_job_summary_path(vacancy.id))
      end
    end

    describe "#publish" do
      scenario "cannot be published unless the details are valid" do
        yesterday_date = Time.zone.yesterday
        vacancy = create(:vacancy, :draft, publish_on: Time.zone.tomorrow, job_roles: %w[teacher])
        vacancy.organisation_vacancies.create(organisation: school)
        vacancy.assign_attributes expires_at: yesterday_date
        vacancy.save(validate: false)

        visit organisation_job_review_path(vacancy.id)

        expect(page).to have_content(I18n.t("jobs.current_step", step: 5, total: 9))
        within("h2.govuk-heading-l") do
          expect(page).to have_content(I18n.t("publishers.vacancies.steps.important_dates"))
        end

        expect(find_field("publishers_job_listing_important_dates_form[expires_at(3i)]").value).to eq(yesterday_date.day.to_s)
        expect(find_field("publishers_job_listing_important_dates_form[expires_at(2i)]").value).to eq(yesterday_date.month.to_s)
        expect(find_field("publishers_job_listing_important_dates_form[expires_at(1i)]").value).to eq(yesterday_date.year.to_s)

        click_on I18n.t("buttons.continue")

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

        click_on I18n.t("buttons.continue")

        click_on I18n.t("buttons.submit_job_listing")
        expect(current_path).to eq(organisation_job_summary_path(vacancy.id))
      end

      scenario "can be published at a later date" do
        vacancy = create(:vacancy, :draft, publish_on: Time.zone.tomorrow, job_roles: %w[teacher])
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)
        click_on "Confirm and submit job"

        expect(page).to have_content("Your job listing will be posted on #{format_date(vacancy.publish_on)}.")
        visit organisation_job_path(vacancy.id)
        expect(page).to have_content(format_date(vacancy.publish_on).to_s)
      end

      scenario "displays the expiration date and time on the confirmation page" do
        vacancy = create(:vacancy, :draft, expires_at: 5.days.from_now.change(hour: 9, minute: 0), job_roles: %w[teacher])
        vacancy.organisation_vacancies.create(organisation: school)
        visit organisation_job_review_path(vacancy.id)
        click_on I18n.t("buttons.submit_job_listing")

        expect(page)
          .to have_content(I18n.t("publishers.vacancies.summary.date_expires",
                                  application_deadline: OrganisationVacancyPresenter.new(vacancy).application_deadline))
      end

      scenario "a published vacancy cannot be republished" do
        vacancy = create(:vacancy, :draft, publish_on: Time.zone.tomorrow, job_roles: %w[teacher])
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)
        click_on "Confirm and submit job"
        expect(page).to have_content("The job listing has been completed")

        visit organisation_job_publish_path(vacancy.id)

        expect(page).to have_content(I18n.t("messages.jobs.already_published"))
      end

      scenario "a published vacancy cannot be edited" do
        vacancy = create(:vacancy, :published)
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)
        expect(page.current_path).to eq(organisation_job_path(vacancy.id))
        expect(page).to have_content(I18n.t("messages.jobs.already_published"))
      end

      context "adds a job to update the Google index in the queue" do
        scenario "if the vacancy is published immediately" do
          vacancy = create(:vacancy, :draft, publish_on: Date.current, job_roles: %w[teacher])
          vacancy.organisation_vacancies.create(organisation: school)

          expect_any_instance_of(Publishers::Vacancies::BaseController)
            .to receive(:update_google_index).with(vacancy)

          visit organisation_job_review_path(vacancy.id)
          click_on I18n.t("buttons.submit_job_listing")
        end
      end
    end
  end
end
