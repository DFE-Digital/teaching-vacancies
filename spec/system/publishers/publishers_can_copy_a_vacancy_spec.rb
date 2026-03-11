require "rails_helper"

RSpec.describe "Copying a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  before { login_publisher(publisher: publisher, organisation: school) }

  after { logout }

  describe "publishing a copied vacancy" do
    let(:original_vacancy) { create(:vacancy, :past_publish, organisations: [school], phases: %w[secondary], key_stages: %w[ks3]) }
    let(:new_template) { VacancyTemplate.order(:created_at).last }

    before { visit organisation_job_path(original_vacancy.id) }

    scenario "a job can be successfully copied and published", :js do
      click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

      # new_vacancy = Vacancy.all.order(:created_at).last
      sleep 20
      expect(current_path).to eq organisation_job_path(new_vacancy.id)
      click_on I18n.t("publishers.vacancies.show.heading_component.action.complete")

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :start_date))
      fill_in_start_date_form_fields
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :include_additional_documents))
      fill_in_include_additional_documents_form_fields(false)
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :important_dates))

      fill_in_important_dates_form_fields(publish_on: Date.current, expires_at: 30.days.from_now)
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_review_path(new_vacancy.id))

      click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")

      expect(page).to have_content(I18n.t("publishers.vacancies.summary.heading.published"))
    end
  end

  context "when the original job is now invalid" do
    let(:original_vacancy) { create(:vacancy, :past_publish, school_offer: nil, organisations: [school], phases: %w[secondary], key_stages: %w[ks3]) }

    before { visit organisation_job_path(original_vacancy.id) }

    scenario "the user is taken through the invalid steps" do
      pending("template copying")

      click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

      new_vacancy = Vacancy.all.order(:created_at).last

      expect(current_path).to eq organisation_job_path(new_vacancy.id)
      click_on I18n.t("publishers.vacancies.show.heading_component.action.complete")

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :start_date))
      fill_in_start_date_form_fields
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :about_the_role))
      new_vacancy.school_offer = "It's a nice place to work"
      fill_in_about_the_role_form_fields(new_vacancy)
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :include_additional_documents))

      fill_in_include_additional_documents_form_fields(false)
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :important_dates))

      fill_in_important_dates_form_fields(publish_on: Date.current, expires_at: 30.days.from_now)
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_review_path(new_vacancy.id))

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

      new_vacancy = Vacancy.all.order(:created_at).last
      expect(current_path).to eq organisation_job_path(new_vacancy.id)
      click_on I18n.t("publishers.vacancies.show.heading_component.action.complete")

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :include_additional_documents))

      fill_in_include_additional_documents_form_fields(false)
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_review_path(new_vacancy.id))
    end
  end
end
