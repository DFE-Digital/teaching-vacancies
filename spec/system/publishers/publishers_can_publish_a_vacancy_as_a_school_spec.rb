require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:vacancy) do
    build(:vacancy,
          :ect_suitable,
          job_roles: ["teacher"],
          phases: %w[secondary],
          key_stages: %w[ks3],
          publish_on: Date.current)
  end
  let(:created_vacancy) { Vacancy.last }

  before { login_publisher(publisher: publisher, organisation: school) }

  after { logout }

  context "non-faith school" do
    let(:school) { create(:school, :not_applicable, name: "Salisbury School") }

    it "follows the flow" do
      visit organisation_jobs_with_type_path
      expect(page).to have_content("Salisbury School")

      click_on I18n.t("buttons.create_job")
      expect(current_path).to eq(organisation_jobs_start_path)
      click_on I18n.t("buttons.create_job")
      expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 1, total: 4))
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_title))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_title))

      fill_in_job_title_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role))

      fill_in_job_role_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :education_phases))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :education_phases))

      fill_in_education_phases_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :key_stages))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :key_stages))

      fill_in_key_stages_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :subjects))

      fill_in_subjects_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contract_type))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contract_type))

      fill_in_contract_type_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :working_patterns))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :working_patterns))

      fill_in_working_patterns_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

      expect_correct_pay_package_options(vacancy)

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

      fill_in_pay_package_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

      fill_in_important_dates_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :start_date))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :start_date))

      fill_in_start_date_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

      # No religious options when not a faith school
      expect(all(".govuk-radios__item").count).to eq(2)
      fill_in_applying_for_the_job_form_fields(vacancy, local_authority_vacancy: false)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :school_visits))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :school_visits))

      fill_in_school_visits_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :visa_sponsorship))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :visa_sponsorship))

      fill_in_visa_sponsorship_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contact_details))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contact_details))

      fill_in_contact_details_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :about_the_role))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :about_the_role))

      fill_in_about_the_role_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :include_additional_documents))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :include_additional_documents))

      fill_in_include_additional_documents_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
      verify_all_vacancy_details(created_vacancy)

      click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
      expect(current_path).to eq(organisation_job_summary_path(created_vacancy.id))
    end

    scenario "saving and finishing later" do
      visit organisation_jobs_with_type_path
      click_on I18n.t("buttons.create_job")
      expect(current_path).to eq(organisation_jobs_start_path)
      click_on I18n.t("buttons.create_job")

      fill_in_job_title_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_job_role_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_education_phases_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_key_stages_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_subjects_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_contract_type_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_working_patterns_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_finish_later")

      expect(current_path).to eq(organisation_job_path(created_vacancy.id))

      has_incomplete_draft_vacancy_review_heading?(created_vacancy)

      click_on I18n.t("publishers.vacancies.show.heading_component.action.complete")

      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

      fill_in_pay_package_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_important_dates_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_start_date_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_applying_for_the_job_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_school_visits_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_visa_sponsorship_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_contact_details_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_about_the_role_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_include_additional_documents_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
      verify_all_vacancy_details(created_vacancy)
    end

    describe "#publish" do
      scenario "cannot be published unless the details are valid" do
        yesterday_date = Time.zone.yesterday
        vacancy = create(:vacancy, :draft, :ect_suitable, job_roles: ["teacher"], organisations: [school], key_stages: %w[ks3], publish_on: Time.zone.today, phases: %w[secondary])
        vacancy.update! expires_at: yesterday_date

        visit organisation_job_path(vacancy.id)
        visit organisation_job_build_path(vacancy.id, :important_dates)

        expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 2, total: 4))
        within("h1.govuk-heading-l") do
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
        choose "8am", name: "publishers_job_listing_important_dates_form[expiry_time]"

        click_on I18n.t("buttons.save_and_continue")

        click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
        expect(current_path).to eq(organisation_job_summary_path(vacancy.id))
      end

      context "when publishing a vacancy" do
        let(:publisher_that_created_vacancy) { create(:publisher, organisations: [trust]) }
        let(:publisher_that_publishes_vacancy) { create(:publisher, organisations: [school]) }
        let(:school) { create(:school) }
        let(:trust) { create(:trust, schools: [school]) }
        let(:vacancy) { create(:vacancy, :draft, organisations: [school], publisher: publisher_that_created_vacancy, publisher_organisation: trust) }

        before { login_publisher(publisher: publisher_that_publishes_vacancy, organisation: school) }

        scenario "the publisher and organisation_publisher are reset" do
          visit organisation_job_path(vacancy.id)

          has_complete_draft_vacancy_review_heading?(vacancy)

          click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")

          vacancy.reload

          expect(vacancy.publisher).to eq(publisher_that_publishes_vacancy)
          expect(vacancy.publisher_organisation).to eq(school)
        end
      end

      scenario "can be published at a later date" do
        vacancy = create(:vacancy, :draft, :ect_suitable, job_roles: ["teacher"], organisations: [school], publish_on: Time.zone.tomorrow, phases: %w[secondary], key_stages: %w[ks3])

        visit organisation_job_path(vacancy.id)
        click_on I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft")

        expect(page).to have_content(I18n.t("publishers.vacancies.summary.date_posted", date: format_date(vacancy.publish_on)))

        visit organisation_job_path(vacancy.id)

        has_scheduled_vacancy_review_heading?(vacancy)
        expect(page).to have_content(format_date(vacancy.publish_on).to_s)
      end

      scenario "can be converted to a draft" do
        vacancy = create(:vacancy, :draft, :ect_suitable, job_roles: ["teacher"], organisations: [school], publish_on: Time.zone.tomorrow, phases: %w[secondary], key_stages: %w[ks3])

        visit organisation_job_path(vacancy.id)
        click_on I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft")

        expect(page).to have_content(I18n.t("publishers.vacancies.summary.date_posted", date: format_date(vacancy.publish_on)))

        visit organisation_job_path(vacancy.id)

        has_scheduled_vacancy_review_heading?(vacancy)

        click_on I18n.t("publishers.vacancies.show.heading_component.action.convert_to_draft")

        has_incomplete_draft_vacancy_review_heading?(vacancy)
      end

      scenario "a published vacancy cannot be republished" do
        vacancy = create(:vacancy, :draft, :ect_suitable, job_roles: ["teacher"], organisations: [school], publish_on: Time.zone.tomorrow, phases: %w[secondary], key_stages: %w[ks3])

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
          vacancy = create(:vacancy, :draft, :ect_suitable, job_roles: ["teacher"], organisations: [school], publish_on: Date.current, key_stages: %w[ks3], phases: %w[secondary])

          expect_any_instance_of(Publishers::Vacancies::BaseController)
            .to receive(:update_google_index).with(vacancy)

          visit organisation_job_path(vacancy.id)
          click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
        end
      end
    end
  end

  context "with a catholic school" do
    let(:school) { create(:school, :catholic) }

    before do
      visit organisation_jobs_with_type_path
      click_on I18n.t("buttons.create_job")

      fill_in_forms_until_start_date(vacancy)

      fill_in_start_date_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
    end

    context "when using the web form" do
      scenario "catholic" do
        find('label[for="publishers-job-listing-applying-for-the-job-form-application-form-type-catholic-field"]').click
        click_on I18n.t("buttons.save_and_continue")

        fill_from_visits_to_review(vacancy)
        expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
        expect(created_vacancy.reload.religion_type.to_sym).to eq(:catholic)
      end

      scenario "Church of England" do
        find('label[for="publishers-job-listing-applying-for-the-job-form-application-form-type-other-religion-field"]').click
        click_on I18n.t("buttons.save_and_continue")

        fill_from_visits_to_review(vacancy)
        expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
        expect(created_vacancy.reload.religion_type.to_sym).to eq(:other_religion)
      end

      scenario "No religion questions" do
        find('label[for="publishers-job-listing-applying-for-the-job-form-application-form-type-no-religion-field"]').click
        click_on I18n.t("buttons.save_and_continue")

        fill_from_visits_to_review(vacancy)
        expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
        expect(created_vacancy.reload.religion_type.to_sym).to eq(:no_religion)
      end
    end

    context "when not using the web form" do
      before do
        choose strip_tags(I18n.t("helpers.label.publishers_job_listing_applying_for_the_job_form.application_form_type_options.other"))
        click_on I18n.t("buttons.save_and_continue")
      end

      it "doesnt ask religion questions" do
        expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :how_to_receive_applications))
        expect(created_vacancy.reload).to have_attributes(enable_job_applications: false, religion_type: nil)
      end
    end
  end

  def fill_from_visits_to_review(vacancy)
    fill_in_school_visits_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")

    fill_in_visa_sponsorship_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")

    fill_in_contact_details_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")

    fill_in_about_the_role_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")

    fill_in_include_additional_documents_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
  end
end
