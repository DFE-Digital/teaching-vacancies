require "rails_helper"

RSpec.describe "Copying a vacancy" do
  let(:publisher) { create(:publisher) }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  after { logout }

  context "when the user is part of a school" do
    let(:organisation) { create(:school) }
    let(:template_name) { Faker::Movie.title }

    describe "creating a template from scratch" do
      before do
        visit organisation_jobs_with_type_path
      end

      let(:new_template) { VacancyTemplate.order(:created_at).last }
      let(:new_draft_vacancy) { DraftVacancy.order(:created_at).last }

      it "bounces when the name is not entered" do
        # acts as a page wait
        expect(page).to have_content "Create a template"
        click_on "Create a template"

        # acts as a page wait
        expect(page).to have_current_path(new_organisation_vacancy_template_path)

        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")
        expect(page).to have_content "Enter a template name"
      end

      it "can be saved later" do
        # acts as a page wait
        expect(page).to have_content "Create a template"
        click_on "Create a template"

        # acts as a page wait
        expect(page).to have_content "Template name"
        expect(page).to have_current_path(new_organisation_vacancy_template_path)

        fill_in "Template name", with: template_name
        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

        check "Teaching assistant"
        click_on I18n.t("buttons.save_and_finish_later")
        expect(page).to have_current_path(organisation_vacancy_templates_path)
      end

      it "bounces on form errors" do
        # acts as a page wait
        expect(page).to have_content "Create a template"
        click_on "Create a template"

        # acts as a page wait
        expect(page).to have_content "Template name"
        expect(page).to have_current_path(new_organisation_vacancy_template_path)

        fill_in "Template name", with: template_name
        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

        expect(page).to have_content "Teaching assistant"
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_content "Select a job role"
      end

      it "doesn't show subjects for primary roles" do
        # acts as a page wait
        expect(page).to have_content "Create a template"
        click_on "Create a template"

        # acts as a page wait
        expect(page).to have_content "Template name"
        expect(page).to have_current_path(new_organisation_vacancy_template_path)

        fill_in "Template name", with: template_name
        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

        expect(page).to have_content "Teaching assistant"
        check "Assistant headteacher"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Nursery"
        check "Primary school"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Key stages"
        check "Key stage 1"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Contract type"
      end

      it "allows the publisher to create a job template" do
        # acts as a page wait
        expect(page).to have_content "Create a template"
        click_on "Create a template"

        # acts as a page wait
        expect(page).to have_content "Template name"
        expect(page).to have_current_path(new_organisation_vacancy_template_path)

        fill_in "Template name", with: template_name
        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

        expect(page).to have_content "Teaching assistant"
        check "Assistant headteacher"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Nursery"
        check "Primary school"
        check "Secondary school"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Key stages"
        check "Key stage 1"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Accounting"
        check "Biology"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Contract type"
        choose "Permanent"
        check "Full time"
        job_share_label = "publishers-job-listing-contract-information-form-is-job-share-false-field"
        find("label[for=#{job_share_label}]").click
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "Salary details"
        check "Full-time equivalent salary"
        fill_in "Full-time equivalent salary", with: "#{Faker::Number.between(from: 1.0, to: 5.0)} #{Faker::CryptoCoin.coin_name}"
        choose "No"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "What skills and experience are you"
        fill_in("publishers-job-listing-about-the-role-form-skills-and-experience-field", with: Faker::Lorem.sentence)
        fill_in("publishers-job-listing-about-the-role-form-school-offer-field", with: Faker::Lorem.sentence)
        within ".flexi_working_details_provided" do
          choose "No"
        end
        within ".further-details-provided-radios" do
          choose "No"
        end
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "school visits"
        choose "Yes"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "sponsorship"
        choose "Yes"
        click_on I18n.t("buttons.save_and_continue")

        choose "Use other application form"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "How do you want candidates to apply"
        choose "By visiting a different website"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content "How would you like to view your applications"
        choose "Anonymously"
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_current_path(organisation_vacancy_templates_path)
        # acts as a page wait
        expect(page).to have_content "Use this template"
        click_on "Use this template"
        expect(page).to have_current_path(organisation_job_build_path(new_draft_vacancy.id, :job_title))
      end
    end

    describe "publishing a vacancy copied from a template" do
      let(:original_vacancy) do
        create(:vacancy, :past_publish, :without_any_money,
               salary: 25_000, organisations: [organisation], subjects: %w[French],
               job_roles: %w[teacher], phases: %w[secondary], key_stages: %w[ks3])
      end
      let(:new_template) { VacancyTemplate.order(:created_at).last }
      let(:template_name) { Faker::Movie.title }

      it "bounces if name is not entered" do
        visit organisation_job_path(original_vacancy.id)

        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

        fill_in "Template name", with: ""
        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")
        expect(page).to have_content "Enter a template name"
      end

      scenario "a job can be successfully copied and published" do
        visit organisation_job_path(original_vacancy.id)

        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

        fill_in "Template name", with: template_name
        click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

        expect(new_template).to have_attributes(name: template_name, job_roles: %w[teacher],
                                                phases: %w[secondary], key_stages: %w[ks3])

        #  causes a wait for the content
        expect(page).to have_content(template_name)
        click_on template_name

        #  causes a wait for the content
        expect(page).to have_content("Change")
        within "#job_role" do
          click_on "Change"
        end
        expect(page).to have_content("Learning support or cover supervisor")
        check "Headteacher"
        click_on I18n.t("buttons.save_and_continue")
        expect(page).to have_current_path(organisation_vacancy_template_path(new_template))
        expect(new_template.reload).to have_attributes(job_roles: %w[teacher headteacher])
        visit organisation_vacancy_templates_path
        # acts as a page wait
        expect(page).to have_content "Use this template"
        click_on "Use this template"
        expect(page).to have_content "Job title"
        fill_in "Job title", with: Faker::Educator.course_name
        click_on I18n.t("buttons.save_and_continue")
        fill_in_start_date_form_fields
        click_on I18n.t("buttons.save_and_continue")
        fill_in_include_additional_documents_form_fields(false)
        click_on I18n.t("buttons.save_and_continue")
        fill_in_important_dates_form_fields(publish_on: Date.current, expires_at: 30.days.from_now)
        click_on I18n.t("buttons.save_and_continue")
        fill_in_contact_details_form_fields(contact_email: publisher.email)
        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")

        expect(page).to have_content(I18n.t("publishers.vacancies.summary.heading.published"))
      end
    end
  end

  context "when the user is part of a trust" do
    let(:organisation) { create(:trust, schools: build_list(:school, 2, phase: :primary)) }

    before do
      create(:vacancy_template, organisation: organisation)
      visit organisation_vacancy_templates_path
    end

    it "takes the user through the location step" do
      # acts as a page wait
      expect(page).to have_content "Use this template"
      click_on "Use this template"
      expect(page).to have_content "Locations where the job is based"
      check organisation.schools.first.name
      click_on I18n.t("buttons.continue")
      expect(page).to have_content "Job title"
      fill_in "Job title", with: Faker::Educator.course_name
      click_on I18n.t("buttons.save_and_continue")

      fill_in_start_date_form_fields
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content("Do you want to upload any additional documents?")
      fill_in_include_additional_documents_form_fields(false)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_important_dates_form_fields(publish_on: Date.current, expires_at: 30.days.from_now)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_contact_details_form_fields(contact_email: publisher.email)
      click_on I18n.t("buttons.save_and_continue")

      click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")

      expect(page).to have_content(I18n.t("publishers.vacancies.summary.heading.published"))
    end
  end
end
