require "rails_helper"

RSpec.describe "Creating a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:created_vacancy) { Vacancy.order(:created_at).last }

  before { login_publisher(publisher: publisher, organisation: school) }

  after { logout }

  context "with a non-faith school" do
    before do
      visit organisation_jobs_with_type_path
      # click through to start page
      click_on I18n.t("buttons.create_job")
      # click through to first job page
      click_on I18n.t("buttons.create_job")
    end

    describe "job title page" do
      let(:school) { create(:school) }

      it "starts on the job title page" do
        expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 1, total: 4))
        expect(publisher_job_title_page).to be_displayed
      end
    end

    context "with an external application form and a school that triggers the key stages form" do
      let(:school) { create(:school, :not_applicable) }

      let(:vacancy) do
        build(:vacancy,
              :ect_suitable,
              :secondary,
              :no_tv_applications,
              publish_on: Date.current)
      end

      it "follows the non-TVS flow" do
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
        publisher_education_phase_page.fill_in_and_submit_form(vacancy.phases.first)
        expect(publisher_key_stage_page).to be_displayed

        submit_empty_form
        expect(publisher_key_stage_page).to be_displayed
        expect(publisher_key_stage_page.errors.map(&:text)).to contain_exactly(I18n.t("key_stages_errors.key_stages.blank"))
        # tick every key stage for the relevant phase
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
        publisher_school_visits_page.fill_in_and_submit_form(vacancy.school_visits)

        expect(publisher_visa_sponsorship_page).to be_displayed
        submit_empty_form
        expect(publisher_visa_sponsorship_page.errors.map(&:text)).to contain_exactly(I18n.t("visa_sponsorship_available_errors.visa_sponsorship_available.inclusion"))
        expect(publisher_visa_sponsorship_page).to be_displayed
        publisher_visa_sponsorship_page.fill_in_and_submit_form(vacancy.visa_sponsorship_available)

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
        publisher_application_link_page.fill_in_and_submit_form(vacancy.application_link)

        expect(publisher_contact_details_page).to be_displayed
        submit_empty_form
        expect(publisher_contact_details_page.errors.map(&:text)).to contain_exactly(
          I18n.t("contact_details_errors.contact_email.blank"),
          I18n.t("contact_details_errors.contact_number_provided.inclusion"),
        )
        expect(publisher_contact_details_page).to be_displayed
        publisher_contact_details_page.fill_in_and_submit_form(vacancy.contact_email, vacancy.contact_number)

        expect(page).to have_current_path(organisation_job_review_path(created_vacancy.id), ignore_query: true)

        click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
        expect(page).to have_current_path(organisation_job_summary_path(created_vacancy.id), ignore_query: true)
      end
    end

    context "with an TVS application form" do
      let(:school) { create(:school) }
      let(:vacancy) do
        build(:vacancy,
              :ect_suitable,
              :secondary,
              publish_on: Date.current)
      end

      context "when on the anonymise applications page" do
        before do
          publisher_job_title_page.fill_in_and_submit_form(vacancy.job_title)
          publisher_job_role_page.fill_in_and_submit_form(vacancy.job_roles.first)
          publisher_key_stage_page.fill_in_and_submit_form(vacancy.key_stages_for_phases)
          publisher_subjects_page.fill_in_and_submit_form(vacancy.subjects)
          publisher_contract_information_page.fill_in_and_submit_form(vacancy)
          publisher_start_date_page.fill_in_and_submit_form(vacancy.starts_on)
          publisher_pay_package_page.fill_in_and_submit_form(vacancy)
          publisher_about_the_role_page.fill_in_and_submit_form(vacancy)
          publisher_include_additional_documents_page.fill_in_and_submit_form(vacancy.include_additional_documents)
          publisher_school_visits_page.fill_in_and_submit_form(vacancy.school_visits)
          publisher_visa_sponsorship_page.fill_in_and_submit_form(vacancy.visa_sponsorship_available)
          publisher_important_dates_page.fill_in_and_submit_form(publish_on: vacancy.publish_on, expires_at: vacancy.expires_at)
          publisher_applying_for_the_job_page.standard_option.click
          click_on I18n.t("buttons.save_and_continue")
        end

        it "handles errors when not given data" do
          expect(publisher_anonymise_applications_page).to be_displayed
          click_on I18n.t("buttons.save_and_continue")
          expect(publisher_anonymise_applications_page.errors.map(&:text)).to eq(["Choose whether to view personal details or not"])
        end
      end

      it "follows the TVS flows" do
        publisher_job_title_page.fill_in_and_submit_form(vacancy.job_title)

        expect(publisher_job_role_page).to be_displayed
        publisher_job_role_page.fill_in_and_submit_form(vacancy.job_roles.first)

        expect(publisher_key_stage_page).to be_displayed
        publisher_key_stage_page.fill_in_and_submit_form(vacancy.key_stages_for_phases)

        expect(publisher_subjects_page).to be_displayed
        publisher_subjects_page.fill_in_and_submit_form(vacancy.subjects)

        expect(publisher_contract_information_page).to be_displayed
        publisher_contract_information_page.fill_in_and_submit_form(vacancy)

        expect(publisher_start_date_page).to be_displayed
        publisher_start_date_page.fill_in_and_submit_form(vacancy.starts_on)

        expect(publisher_pay_package_page).to be_displayed
        expect_correct_pay_package_options(vacancy)
        publisher_pay_package_page.fill_in_and_submit_form(vacancy)

        expect(publisher_about_the_role_page).to be_displayed
        publisher_about_the_role_page.fill_in_and_submit_form(vacancy)

        expect(publisher_include_additional_documents_page).to be_displayed
        publisher_include_additional_documents_page.fill_in_and_submit_form(vacancy.include_additional_documents)

        expect(publisher_school_visits_page).to be_displayed
        publisher_school_visits_page.fill_in_and_submit_form(vacancy.school_visits)

        expect(publisher_visa_sponsorship_page).to be_displayed
        publisher_visa_sponsorship_page.fill_in_and_submit_form(vacancy.visa_sponsorship_available)

        expect(publisher_important_dates_page).to be_displayed
        publisher_important_dates_page.fill_in_and_submit_form(publish_on: vacancy.publish_on, expires_at: vacancy.expires_at)

        expect(publisher_applying_for_the_job_page).to be_displayed
        publisher_applying_for_the_job_page.standard_option.click
        click_on I18n.t("buttons.save_and_continue")

        expect(publisher_anonymise_applications_page).to be_displayed
        publisher_anonymise_applications_page.anonymous_option.click
        click_on "Save and continue"

        expect(publisher_contact_details_page).to be_displayed
        non_publisher_email = "new.contact@example.com"
        publisher_contact_details_page.fill_in_and_submit_form(non_publisher_email, vacancy.contact_number)

        # Should now see the confirm_contact_details page
        expect(publisher_confirm_contact_details_page).to be_displayed
        expect(page).to have_content("Do you want to use this email address?")
        
        # Test selecting "Yes" to confirm the email
        publisher_confirm_contact_details_page.fill_in_and_submit_form(confirm: true)

        expect(page).to have_current_path(organisation_job_review_path(created_vacancy.id), ignore_query: true)

        click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
        expect(page).to have_current_path(organisation_job_summary_path(created_vacancy.id), ignore_query: true)
      end
    end

    describe "#publish" do
      let(:school) { create(:school) }

      context "when publishing a vacancy" do
        let(:publisher_that_created_vacancy) { create(:publisher, organisations: [trust]) }
        let(:publisher_that_publishes_vacancy) { create(:publisher, organisations: [school]) }
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

      it "can be published at a later date" do
        vacancy = create(:draft_vacancy, :ect_suitable, :secondary, job_roles: %w[teacher], organisations: [school], publish_on: Time.zone.tomorrow)

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
        vacancy = create(:draft_vacancy, :ect_suitable, :secondary, job_roles: %w[teacher], organisations: [school], publish_on: Time.zone.tomorrow)

        visit organisation_job_path(vacancy.id)
        click_on I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft")

        expect(page).to have_content(I18n.t("publishers.vacancies.summary.date_posted", date: format_date(vacancy.publish_on)))

        click_on "make changes to the job listing"

        has_scheduled_vacancy_review_heading?(vacancy)

        click_on I18n.t("publishers.vacancies.show.heading_component.action.convert_to_draft")

        has_incomplete_draft_vacancy_review_heading?(vacancy)
      end

      scenario "a published vacancy cannot be republished" do
        vacancy = create(:draft_vacancy, :secondary, :ect_suitable, job_roles: %w[teacher], organisations: [school], publish_on: Time.zone.tomorrow)

        visit organisation_job_path(vacancy.id)

        expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft"))
      end

      context "when the vacancy is published immediately" do
        let(:vacancy) { create(:draft_vacancy, :secondary, :ect_suitable, job_roles: %w[teacher], organisations: [school], publish_on: Date.current) }

        it "adds a job to update the Google index in the queue" do
          expect(UpdateGoogleIndexQueueJob).to receive(:perform_later)

          visit organisation_job_path(vacancy.id)
          click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
        end
      end
    end
  end

  context "with a catholic school" do
    let(:school) { create(:school, :catholic) }
    let(:vacancy) do
      build(:vacancy,
            :secondary,
            :no_tv_applications,
            publish_on: Date.current)
    end

    before do
      visit organisation_jobs_with_type_path
      click_on I18n.t("buttons.create_job")
      click_on I18n.t("buttons.create_job")

      fill_in_forms_until_applying_for(vacancy, created_vacancy.id)
    end

    context "when using the web form" do
      scenario "catholic" do
        publisher_applying_for_the_job_page.catholic_option.click
        click_on I18n.t("buttons.save_and_continue")

        fill_from_anonymise_to_review(vacancy)
        expect(page).to have_current_path(organisation_job_review_path(created_vacancy.id), ignore_query: true)
        expect(DraftVacancy.find(created_vacancy.id)).to be_catholic
      end

      scenario "Church of England" do
        find('label[for="publishers-job-listing-applying-for-the-job-form-application-form-type-other-religion-field"]').click
        click_on I18n.t("buttons.save_and_continue")

        fill_from_anonymise_to_review(vacancy)
        expect(page).to have_current_path(organisation_job_review_path(created_vacancy.id), ignore_query: true)
        expect(DraftVacancy.find(created_vacancy.id)).to be_other_religion
      end

      scenario "No religion questions" do
        publisher_applying_for_the_job_page.standard_option.click
        click_on I18n.t("buttons.save_and_continue")

        fill_from_anonymise_to_review(vacancy)
        expect(page).to have_current_path(organisation_job_review_path(created_vacancy.id), ignore_query: true)
        expect(DraftVacancy.find(created_vacancy.id)).to be_no_religion
      end
    end

    context "when not using the web form" do
      before do
        choose strip_tags(I18n.t("helpers.label.publishers_job_listing_applying_for_the_job_form.application_form_type_options.other"))
        click_on I18n.t("buttons.save_and_continue")
      end

      it "doesnt ask religion questions" do
        expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :how_to_receive_applications), ignore_query: true)
        expect(DraftVacancy.find(created_vacancy.id)).to have_attributes(enable_job_applications: false, religion_type: nil)
      end
    end
  end

  def fill_from_anonymise_to_review(vacancy)
    expect(publisher_anonymise_applications_page).to be_displayed
    publisher_anonymise_applications_page.standard_option.click
    click_on "Save and continue"

    fill_in_contact_details_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
  end

  def submit_empty_form
    click_on I18n.t("buttons.save_and_continue")
  end
end
