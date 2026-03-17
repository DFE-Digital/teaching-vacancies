require "rails_helper"

RSpec.describe "Creating and using templates" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  before { login_publisher(publisher: publisher, organisation: school) }

  after { logout }

  describe "creating a template from scratch" do
    before do
      visit organisation_jobs_with_type_path
    end

    let(:new_template) { VacancyTemplate.order(:created_at).last }
    let(:template_name) { Faker::Movie.title }

    it "allows the publisher to create a job template" do
      # acts as a page wait
      expect(page).to have_content "Create a template"
      click_on "Create a template"

      # acts as a page wait
      expect(page).to have_content "Template name"
      expect(page).to have_current_path(new_organisation_vacancy_template_path)

      fill_in "Template name", with: template_name
      click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

      check "Teaching assistant"
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
      choose "No"
      # TODO: - this seems to not insist on a pay rate
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
    end
  end

  context "when the original job is now invalid" do
    let(:original_vacancy) { create(:vacancy, :past_publish, school_offer: nil, organisations: [school], phases: %w[secondary], key_stages: %w[ks3]) }

    before { visit organisation_job_path(original_vacancy.id) }

    scenario "the user is taken through the invalid steps" do
      pending("template copying")

      click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

      new_vacancy = Vacancy.order(:created_at).last

      expect(page).to have_current_path organisation_job_path(new_vacancy.id), ignore_query: true
      click_on I18n.t("publishers.vacancies.show.heading_component.action.complete")

      expect(page).to have_current_path(organisation_job_build_path(new_vacancy.id, :start_date), ignore_query: true)
      fill_in_start_date_form_fields
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path(organisation_job_build_path(new_vacancy.id, :about_the_role), ignore_query: true)
      new_vacancy.school_offer = "It's a nice place to work"
      fill_in_about_the_role_form_fields(new_vacancy)
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path(organisation_job_build_path(new_vacancy.id, :include_additional_documents), ignore_query: true)

      fill_in_include_additional_documents_form_fields(false)
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path(organisation_job_build_path(new_vacancy.id, :important_dates), ignore_query: true)

      fill_in_important_dates_form_fields(publish_on: Date.current, expires_at: 30.days.from_now)
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path(organisation_job_review_path(new_vacancy.id), ignore_query: true)

      click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")

      expect(page).to have_content(I18n.t("publishers.vacancies.summary.heading.published"))
    end
  end

  context "when the original job is pending/scheduled/future_publish" do
    let!(:original_vacancy) { create(:vacancy, :future_publish, organisations: [school]) }

    scenario "the dates are pre-filled" do
      pending("template copying")

      visit organisation_jobs_with_type_path(type: "pending")
      click_on original_vacancy.job_title
      click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

      new_vacancy = Vacancy.order(:created_at).last
      expect(page).to have_current_path organisation_job_path(new_vacancy.id), ignore_query: true
      click_on I18n.t("publishers.vacancies.show.heading_component.action.complete")

      expect(page).to have_current_path(organisation_job_build_path(new_vacancy.id, :include_additional_documents), ignore_query: true)

      fill_in_include_additional_documents_form_fields(false)
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path(organisation_job_review_path(new_vacancy.id), ignore_query: true)
    end
  end
end
