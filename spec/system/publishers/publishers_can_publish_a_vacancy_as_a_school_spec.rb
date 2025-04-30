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
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("job_title_errors.job_title.blank"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_title))

      fill_in_job_title_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("job_roles_errors.job_roles.blank"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :job_role))

      fill_in_job_role_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :education_phases))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("education_phases_errors.phases.blank"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :education_phases))

      fill_in_education_phases_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :key_stages))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("key_stages_errors.key_stages.blank"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :key_stages))

      fill_in_key_stages_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :subjects))

      fill_in_subjects_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contract_information))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("contract_information_errors.contract_type.inclusion"))
        expect(page).to have_content(I18n.t("contract_information_errors.working_patterns.inclusion"))
        expect(page).to have_content(I18n.t("contract_information_errors.is_job_share.inclusion"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contract_information))

      fill_in_contract_information_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

      expect_correct_pay_package_options(vacancy)

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("pay_package_errors.salary_types.invalid"))
        expect(page).to have_content(I18n.t("pay_package_errors.benefits.inclusion"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :pay_package))

      fill_in_pay_package_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("important_dates_errors.publish_on_day.inclusion"))
        expect(page).to have_content(I18n.t("important_dates_errors.expires_at.blank"))
        expect(page).to have_content(I18n.t("important_dates_errors.expiry_time.inclusion"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :important_dates))

      fill_in_with_expiry_date_before_publish_date(vacancy)

      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("important_dates_errors.expires_at.after"))
      end

      fill_in_important_dates_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :start_date))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("start_date_errors.start_date_type.inclusion"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :start_date))

      fill_in_start_date_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :applying_for_the_job))

      expect(all(".govuk-radios__item").count).to eq(2)
      fill_in_applying_for_the_job_form_fields(vacancy, local_authority_vacancy: false)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :school_visits))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("school_visits_errors.school_visits.inclusion"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :school_visits))

      fill_in_school_visits_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :visa_sponsorship))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("visa_sponsorship_available_errors.visa_sponsorship_available.inclusion"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :visa_sponsorship))

      fill_in_visa_sponsorship_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contact_details))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("contact_details_errors.contact_email.blank"))
        expect(page).to have_content(I18n.t("contact_details_errors.contact_number_provided.inclusion"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :contact_details))

      fill_in_contact_details_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :about_the_role))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("about_the_role_errors.ect_status.inclusion"))
        expect(page).to have_content(I18n.t("about_the_role_errors.skills_and_experience.blank"))
        expect(page).to have_content(I18n.t("about_the_role_errors.further_details_provided.inclusion"))
        expect(page).to have_content(I18n.t("about_the_role_errors.school_offer.blank", organisation: "school"))
        expect(page).to have_content(I18n.t("about_the_role_errors.flexi_working_details_provided.inclusion"))
      end
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :about_the_role))

      fill_in_about_the_role_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")
      expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :include_additional_documents))

      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_content("There is a problem")
      within(".govuk-error-summary") do
        expect(page).to have_content(I18n.t("include_additional_documents_errors.include_additional_documents.inclusion"))
      end
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

      fill_in_contract_information_form_fields(vacancy)
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
      context "when publishing a vacancy" do
        let(:publisher_that_created_vacancy) { create(:publisher, organisations: [trust]) }
        let(:publisher_that_publishes_vacancy) { create(:publisher, organisations: [school]) }
        let(:school) { create(:school) }
        let(:trust) { create(:trust, schools: [school]) }
        let(:vacancy) { create(:vacancy, :draft, organisations: [school], publisher: publisher_that_created_vacancy, publisher_organisation: trust) }

        before { login_publisher(publisher: publisher_that_publishes_vacancy, organisation: school) }

        after { logout }

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
        #  wait for page to load
        find(".govuk-panel.govuk-panel--confirmation")

        expect(page).to have_content(I18n.t("publishers.vacancies.summary.date_posted", date: format_date(vacancy.publish_on)))

        click_on "make changes to the job listing"

        has_scheduled_vacancy_review_heading?(vacancy)
        expect(page).to have_content(format_date(vacancy.publish_on).to_s)
      end

      scenario "can be converted to a draft" do
        vacancy = create(:vacancy, :draft, :ect_suitable, job_roles: ["teacher"], organisations: [school], publish_on: Time.zone.tomorrow, phases: %w[secondary], key_stages: %w[ks3])

        visit organisation_job_path(vacancy.id)
        click_on I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft")

        expect(page).to have_content(I18n.t("publishers.vacancies.summary.date_posted", date: format_date(vacancy.publish_on)))

        click_on "make changes to the job listing"

        has_scheduled_vacancy_review_heading?(vacancy)

        click_on I18n.t("publishers.vacancies.show.heading_component.action.convert_to_draft")

        has_incomplete_draft_vacancy_review_heading?(vacancy)
      end

      scenario "a draft vacancy with a publish_on date can not be set to publish more than once, but publish date can be edited" do
        vacancy = create(:vacancy, :draft, :ect_suitable, job_roles: ["teacher"], organisations: [school], publish_on: Time.zone.tomorrow, phases: %w[secondary], key_stages: %w[ks3])

        visit organisation_job_path(vacancy.id)
        expect(page).to_not have_content(I18n.t("publishers.vacancies.show.heading_component.action.publish"))
        expect(page).to have_content "Change Publish date"
      end

      scenario "a published vacancy cannot be edited or republished" do
        vacancy = create(:vacancy, :published, organisations: [school])

        visit organisation_job_path(vacancy.id)
        expect(page.current_path).to eq(organisation_job_path(vacancy.id))
        has_published_vacancy_review_heading?(vacancy)
        expect(page).to_not have_content(I18n.t("publishers.vacancies.show.heading_component.action.publish"))
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

  def fill_in_with_expiry_date_before_publish_date(vacancy)
    fill_in "publishers_job_listing_important_dates_form[publish_on(3i)]", with: vacancy.publish_on.day
    fill_in "publishers_job_listing_important_dates_form[publish_on(2i)]", with: vacancy.publish_on.month
    fill_in "publishers_job_listing_important_dates_form[publish_on(1i)]", with: vacancy.publish_on.year

    fill_in "publishers_job_listing_important_dates_form[expires_at(3i)]", with: Time.zone.yesterday.day
    fill_in "publishers_job_listing_important_dates_form[expires_at(2i)]", with: Time.zone.yesterday.month
    fill_in "publishers_job_listing_important_dates_form[expires_at(1i)]", with: Time.zone.yesterday.year
  end
end
