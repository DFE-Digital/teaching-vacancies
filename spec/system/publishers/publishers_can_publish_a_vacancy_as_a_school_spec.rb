require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:vacancy) do
    build(:vacancy,
          :ect_suitable,
          :no_tv_applications,
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

      expect(publisher_job_title_page).to be_displayed
      submit_empty_form
      expect(publisher_job_title_page).to be_displayed
      expect(publisher_job_title_page.errors.map(&:text)).to contain_exactly(I18n.t("job_title_errors.job_title.blank"))
      publisher_job_title_page.fill_in_and_submit_form(vacancy.job_title)

      expect(publisher_job_role_page).to be_displayed
      submit_empty_form
      expect(publisher_job_role_page).to be_displayed
      expect(publisher_job_role_page.errors.map(&:text)).to contain_exactly(I18n.t("job_roles_errors.job_roles.blank"))
      publisher_job_role_page.fill_in_and_submit_form(vacancy.job_roles.first)

      expect(publisher_education_phase_page).to be_displayed
      submit_empty_form
      expect(publisher_education_phase_page).to be_displayed
      expect(publisher_education_phase_page.errors.map(&:text)).to contain_exactly(I18n.t("education_phases_errors.phases.blank"))
      publisher_education_phase_page.fill_in_and_submit_form(vacancy)

      expect(publisher_key_stage_page).to be_displayed
      submit_empty_form
      expect(publisher_key_stage_page).to be_displayed
      expect(publisher_key_stage_page.errors.map(&:text)).to contain_exactly(I18n.t("key_stages_errors.key_stages.blank"))
      publisher_key_stage_page.fill_in_and_submit_form(vacancy.key_stages_for_phases)

      expect(publisher_subjects_page).to be_displayed
      publisher_subjects_page.fill_in_and_submit_form(vacancy.subjects)

      expect(publisher_contract_information_page).to be_displayed
      submit_empty_form
      expect(publisher_contract_information_page).to be_displayed
      expect(publisher_contract_information_page.errors.map(&:text)).to contain_exactly(
        I18n.t("contract_information_errors.contract_type.inclusion"),
        I18n.t("contract_information_errors.working_patterns.inclusion"),
        I18n.t("contract_information_errors.is_job_share.inclusion"),
      )
      publisher_contract_information_page.fill_in_and_submit_form(vacancy)

      expect(publisher_start_date_page).to be_displayed
      submit_empty_form
      expect(publisher_start_date_page).to be_displayed
      expect(publisher_start_date_page.errors.map(&:text)).to contain_exactly(I18n.t("start_date_errors.start_date_type.inclusion"))
      publisher_start_date_page.fill_in_and_submit_form(vacancy.starts_on)

      expect(publisher_pay_package_page).to be_displayed
      submit_empty_form
      expect(publisher_pay_package_page).to be_displayed
      expect(publisher_pay_package_page.errors.map(&:text)).to contain_exactly(
        I18n.t("pay_package_errors.salary_types.invalid"),
        I18n.t("pay_package_errors.benefits.inclusion"),
      )
      expect_correct_pay_package_options(vacancy)
      publisher_pay_package_page.fill_in_and_submit_form(vacancy)

      expect(publisher_about_the_role_page).to be_displayed
      submit_empty_form
      expect(publisher_about_the_role_page).to be_displayed
      expect(publisher_about_the_role_page.errors.map(&:text)).to contain_exactly(
        I18n.t("about_the_role_errors.ect_status.inclusion"),
        I18n.t("about_the_role_errors.skills_and_experience.blank"),
        I18n.t("about_the_role_errors.further_details_provided.inclusion"),
        I18n.t("about_the_role_errors.school_offer.blank", organisation: "school"),
        I18n.t("about_the_role_errors.flexi_working_details_provided.inclusion"),
      )
      publisher_about_the_role_page.fill_in_and_submit_form(vacancy)

      expect(publisher_include_additional_documents_page).to be_displayed
      submit_empty_form
      expect(publisher_include_additional_documents_page.errors.map(&:text)).to contain_exactly(I18n.t("include_additional_documents_errors.include_additional_documents.inclusion"))
      publisher_include_additional_documents_page.fill_in_and_submit_form(vacancy.include_additional_documents)

      expect(publisher_school_visits_page).to be_displayed
      submit_empty_form
      expect(publisher_school_visits_page).to be_displayed
      expect(publisher_school_visits_page.errors.map(&:text)).to contain_exactly(I18n.t("school_visits_errors.school_visits.inclusion"))
      publisher_school_visits_page.fill_in_and_submit_form(vacancy)

      expect(publisher_visa_sponsorship_page).to be_displayed
      submit_empty_form
      expect(publisher_visa_sponsorship_page.errors.map(&:text)).to contain_exactly(I18n.t("visa_sponsorship_available_errors.visa_sponsorship_available.inclusion"))
      expect(publisher_visa_sponsorship_page).to be_displayed
      publisher_visa_sponsorship_page.fill_in_and_submit_form(vacancy)

      expect(publisher_important_dates_page).to be_displayed
      submit_empty_form
      expect(publisher_important_dates_page).to be_displayed
      expect(publisher_important_dates_page.errors.map(&:text)).to contain_exactly(
        I18n.t("important_dates_errors.publish_on_day.inclusion"),
        I18n.t("important_dates_errors.expires_at.blank"),
        I18n.t("important_dates_errors.expiry_time.inclusion"),
      )
      publisher_important_dates_page.fill_in_and_submit_form(publish_on: vacancy.publish_on, expires_at: Time.zone.yesterday)
      expect(publisher_important_dates_page.errors.map(&:text)).to contain_exactly(I18n.t("important_dates_errors.expires_at.after"))
      publisher_important_dates_page.fill_in_and_submit_form(publish_on: vacancy.publish_on, expires_at: vacancy.expires_at)

      expect(publisher_applying_for_the_job_page).to be_displayed
      submit_empty_form
      expect(publisher_applying_for_the_job_page).to be_displayed
      expect(publisher_applying_for_the_job_page.errors.map(&:text)).to contain_exactly(I18n.t("applying_for_the_job_errors.application_form_type.blank"))

      # No religious options when not a faith school
      expect(all(".govuk-radios__item").count).to eq(2)
      publisher_applying_for_the_job_page.fill_in_and_submit_form

      expect(publisher_how_to_receive_applications_page).to be_displayed
      submit_empty_form
      expect(publisher_how_to_receive_applications_page).to be_displayed
      expect(publisher_how_to_receive_applications_page.errors.map(&:text)).to contain_exactly(I18n.t("how_to_receive_applications_errors.receive_applications.inclusion"))
      publisher_how_to_receive_applications_page.fill_in_and_submit_form(vacancy)

      expect(publisher_application_link_page).to be_displayed
      submit_empty_form
      expect(publisher_application_link_page.errors.map(&:text)).to contain_exactly(I18n.t("application_link_errors.application_link.blank"))
      expect(publisher_application_link_page).to be_displayed
      publisher_application_link_page.fill_in_and_submit_form(vacancy)

      expect(publisher_contact_details_page).to be_displayed
      submit_empty_form
      expect(publisher_contact_details_page.errors.map(&:text)).to contain_exactly(
        I18n.t("contact_details_errors.contact_email.blank"),
        I18n.t("contact_details_errors.contact_number_provided.inclusion"),
      )
      expect(publisher_contact_details_page).to be_displayed
      publisher_contact_details_page.fill_in_and_submit_form(vacancy)

      expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))

      click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
      expect(current_path).to eq(organisation_job_summary_path(created_vacancy.id))
    end

    describe "#publish" do
      context "when publishing a vacancy" do
        let(:publisher_that_created_vacancy) { create(:publisher, organisations: [trust]) }
        let(:publisher_that_publishes_vacancy) { create(:publisher, organisations: [school]) }
        let(:school) { create(:school) }
        let(:trust) { create(:trust, schools: [school]) }
        let(:vacancy) { create(:draft_vacancy, organisations: [school], publisher: publisher_that_created_vacancy, publisher_organisation: trust) }

        before { login_publisher(publisher: publisher_that_publishes_vacancy, organisation: school) }

        after { logout }

        scenario "the publisher and organisation_publisher are reset" do
          visit organisation_job_path(vacancy.id)

          click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")

          expect(PublishedVacancy.find(vacancy.id).publisher).to eq(publisher_that_publishes_vacancy)
          expect(PublishedVacancy.find(vacancy.id).publisher_organisation).to eq(school)
        end
      end

      scenario "can be published at a later date" do
        vacancy = create(:draft_vacancy, :ect_suitable, job_roles: ["teacher"], organisations: [school], publish_on: Time.zone.tomorrow, phases: %w[secondary], key_stages: %w[ks3])

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
        vacancy = create(:draft_vacancy, :ect_suitable, job_roles: ["teacher"], organisations: [school], publish_on: Time.zone.tomorrow, phases: %w[secondary], key_stages: %w[ks3])

        visit organisation_job_path(vacancy.id)
        click_on I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft")

        expect(page).to have_content(I18n.t("publishers.vacancies.summary.date_posted", date: format_date(vacancy.publish_on)))

        click_on "make changes to the job listing"

        has_scheduled_vacancy_review_heading?(vacancy)

        click_on I18n.t("publishers.vacancies.show.heading_component.action.convert_to_draft")

        has_incomplete_draft_vacancy_review_heading?(vacancy)
      end

      scenario "a published vacancy cannot be republished" do
        vacancy = create(:draft_vacancy, :ect_suitable, job_roles: ["teacher"], organisations: [school], publish_on: Time.zone.tomorrow, phases: %w[secondary], key_stages: %w[ks3])

        visit organisation_job_path(vacancy.id)

        expect(page).to_not have_content(I18n.t("publishers.vacancies.show.heading_component.action.publish"))
      end

      context "adds a job to update the Google index in the queue" do
        scenario "if the vacancy is published immediately" do
          vacancy = create(:draft_vacancy, :ect_suitable, job_roles: ["teacher"], organisations: [school], publish_on: Date.current, key_stages: %w[ks3], phases: %w[secondary])

          expect_any_instance_of(Publishers::Vacancies::BaseController)
            .to receive(:update_google_index).with(Vacancy.find(vacancy.id))

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

      fill_in_forms_until_applying_for(vacancy)
    end

    context "when using the web form" do
      scenario "catholic" do
        find('label[for="publishers-job-listing-applying-for-the-job-form-application-form-type-catholic-field"]').click
        click_on I18n.t("buttons.save_and_continue")

        fill_from_visits_to_review(vacancy)
        expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
        expect(Vacancy.find(created_vacancy.id).religion_type.to_sym).to eq(:catholic)
      end

      scenario "Church of England" do
        find('label[for="publishers-job-listing-applying-for-the-job-form-application-form-type-other-religion-field"]').click
        click_on I18n.t("buttons.save_and_continue")

        fill_from_visits_to_review(vacancy)
        expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
        expect(Vacancy.find(created_vacancy.id).religion_type.to_sym).to eq(:other_religion)
      end

      scenario "No religion questions" do
        find('label[for="publishers-job-listing-applying-for-the-job-form-application-form-type-no-religion-field"]').click
        click_on I18n.t("buttons.save_and_continue")

        fill_from_visits_to_review(vacancy)
        expect(current_path).to eq(organisation_job_review_path(created_vacancy.id))
        expect(Vacancy.find(created_vacancy.id).religion_type.to_sym).to eq(:no_religion)
      end
    end

    context "when not using the web form" do
      before do
        choose strip_tags(I18n.t("helpers.label.publishers_job_listing_applying_for_the_job_form.application_form_type_options.other"))
        click_on I18n.t("buttons.save_and_continue")
      end

      it "doesnt ask religion questions" do
        expect(current_path).to eq(organisation_job_build_path(created_vacancy.id, :how_to_receive_applications))
        expect(Vacancy.find(created_vacancy.id)).to have_attributes(enable_job_applications: false, religion_type: "no_religion")
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
  end

  def submit_empty_form
    click_on I18n.t("buttons.save_and_continue")
  end
end
