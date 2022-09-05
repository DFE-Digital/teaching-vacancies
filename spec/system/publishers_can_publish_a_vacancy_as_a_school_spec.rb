require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school, :not_applicable, name: "Salisbury School") }

  before { login_publisher(publisher: publisher, organisation: school) }

  scenario "Visiting the school page" do
    visit organisation_path

    expect(page).to have_content("Salisbury School")

    click_on I18n.t("buttons.create_job")

    expect(page).to have_content(I18n.t("jobs.current_step", step: 1, total: 9))
  end

  context "creating a new vacancy" do
    let(:vacancy) do
      VacancyPresenter.new(build(:vacancy,
                                 :teacher,
                                 :ect_suitable,
                                 phases: %w[secondary],
                                 key_stages: %w[ks3],
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

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_details))

      fill_in_job_details_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :working_patterns))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :working_patterns))

      fill_in_working_patterns_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

      fill_in_pay_package_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

      fill_in_important_dates_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

      fill_in_applying_for_the_job_form_fields(vacancy, local_authority_vacancy: false)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job_details))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_application_forms_path(created_vacancy.id))

      fill_in_applying_for_the_job_details_form_fields(vacancy, local_authority_vacancy: false)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_documents_path(created_vacancy.id))

      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_summary))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_summary))

      fill_in_job_summary_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_path(created_vacancy.id))
      has_complete_draft_vacancy_review_heading?(vacancy)
      verify_all_vacancy_details(created_vacancy)

      click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
      expect(current_path).to eq(organisation_job_summary_path(created_vacancy.id))
    end

    scenario "saving and finishing later" do
      visit organisation_path
      click_on I18n.t("buttons.create_job")

      fill_in_job_role_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_ect_status_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_education_phases_form_fields(vacancy)
      click_on I18n.t("buttons.continue")

      fill_in_job_details_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_working_patterns_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_finish_later")

      expect(current_path).to eq(organisation_job_path(created_vacancy.id))

      has_incomplete_draft_vacancy_review_heading?(vacancy)

      click_on I18n.t("publishers.vacancies.show.heading_component.action.complete")

      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

      fill_in_pay_package_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_important_dates_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_applying_for_the_job_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_applying_for_the_job_details_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      click_on I18n.t("buttons.save_and_continue")

      fill_in_job_summary_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      has_complete_draft_vacancy_review_heading?(vacancy)
      verify_all_vacancy_details(created_vacancy)
    end

    describe "#publish" do
      scenario "cannot be published unless the details are valid" do
        yesterday_date = Time.zone.yesterday

        vacancy = create(:vacancy, :draft, :teacher, :ect_suitable, organisations: [school], publish_on: Time.zone.today, phases: %w[secondary], key_stages: %w[ks3])
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

        click_on I18n.t("buttons.save_and_continue")

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

        click_on I18n.t("buttons.save_and_continue")

        click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
        expect(current_path).to eq(organisation_job_summary_path(vacancy.id))
      end

      scenario "can be published at a later date" do
        vacancy = create(:vacancy, :draft, :teacher, :ect_suitable, organisations: [school], publish_on: Time.zone.tomorrow, phases: %w[secondary], key_stages: %w[ks3])

        visit organisation_job_path(vacancy.id)
        click_on I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft")

        expect(page).to have_content(I18n.t("publishers.vacancies.summary.date_posted", date: format_date(vacancy.publish_on)))
        visit organisation_job_path(vacancy.id)
        expect(page).to have_content(format_date(vacancy.publish_on).to_s)
      end

      scenario "a published vacancy cannot be republished" do
        vacancy = create(:vacancy, :draft, :teacher, :ect_suitable, organisations: [school], publish_on: Time.zone.tomorrow, phases: %w[secondary], key_stages: %w[ks3])

        visit organisation_job_path(vacancy.id)

        expect(page).to_not have_content(I18n.t("publishers.vacancies.show.heading_component.action.publish"))
      end

      scenario "a published vacancy cannot be edited" do
        vacancy = create(:vacancy, :published, organisations: [school])

        visit organisation_job_path(vacancy.id)
        expect(page.current_path).to eq(organisation_job_path(vacancy.id))
        has_published_vacancy_review_heading?(vacancy)
      end

      context "adds a job to update the Google index in the queue" do
        scenario "if the vacancy is published immediately" do
          vacancy = create(:vacancy, :draft, :teacher, :ect_suitable, organisations: [school], publish_on: Date.current, phases: %w[secondary], key_stages: %w[ks3])

          expect_any_instance_of(Publishers::Vacancies::BaseController)
            .to receive(:update_google_index).with(vacancy)

          visit organisation_job_path(vacancy.id)
          click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
        end
      end
    end
  end
end
