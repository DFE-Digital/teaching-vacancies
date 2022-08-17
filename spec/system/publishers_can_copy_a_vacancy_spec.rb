require "rails_helper"

RSpec.describe "Copying a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  let!(:original_vacancy) { create_published_vacancy(organisations: [school], phases: %w[secondary], key_stages: %w[ks3]) }

  before { login_publisher(publisher: publisher, organisation: school) }

  RSpec.shared_examples "publishing a copied vacancy" do |options|
    before { visit organisation_path(type: options[:type]) }

    scenario "a job can be successfully copied and published" do
      click_on original_vacancy.job_title
      click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

      new_vacancy = Vacancy.all.order(:created_at).last

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :important_dates))

      new_vacancy.publish_on = Date.current
      new_vacancy.expires_at = 30.days.from_now

      fill_in_important_dates_form_fields(new_vacancy)
      click_on I18n.t("buttons.save_and_continue")

      new_vacancy.start_date_type = "specific_date"
      new_vacancy.starts_on = 35.days.from_now
      fill_in_start_date_form_fields(new_vacancy)
      click_on I18n.t("buttons.save_and_continue")

      has_complete_draft_vacancy_review_heading?(new_vacancy)

      click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")

      expect(page).to have_content(I18n.t("publishers.vacancies.summary.heading.published"))
    end
  end

  include_examples "publishing a copied vacancy", type: "published"

  scenario "a job can be copied from the dashboard" do
    visit organisation_path
    click_on "#{I18n.t('buttons.copy_listing')} #{original_vacancy.job_title}"

    new_vacancy = Vacancy.all.order(:created_at).last

    expect(current_path).to eq organisation_job_build_path(new_vacancy.id, :important_dates)
  end

  context "when the original job is now invalid" do
    let!(:original_vacancy) do
      create_published_vacancy(school_offer: nil, organisations: [school], phases: %w[secondary], key_stages: %w[ks3]) do |vacancy|
        vacancy.send(:set_slug)
      end
    end

    scenario "the user is taken through the invalid steps" do
      visit organisation_path
      click_on original_vacancy.job_title
      click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

      new_vacancy = Vacancy.all.order(:created_at).last

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :important_dates))

      new_vacancy.publish_on = Date.current
      new_vacancy.expires_at = 30.days.from_now

      fill_in_important_dates_form_fields(new_vacancy)
      click_on I18n.t("buttons.save_and_continue")

      new_vacancy.start_date_type = "specific_date"
      new_vacancy.starts_on = 35.days.from_now
      fill_in_start_date_form_fields(new_vacancy)
      click_on I18n.t("buttons.save_and_continue")

      new_vacancy.school_offer = "It's a nice place to work"
      fill_in_about_the_role_form_fields(new_vacancy)
      click_on I18n.t("buttons.save_and_continue")

      has_complete_draft_vacancy_review_heading?(new_vacancy)

      click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")

      expect(page).to have_content(I18n.t("publishers.vacancies.summary.heading.published"))
    end
  end

  context "when the original job is pending/scheduled/future_publish" do
    let!(:original_vacancy) { create(:vacancy, :future_publish, organisations: [school]) }

    scenario "the dates are pre-filled" do
      visit organisation_path(type: "pending")
      click_on original_vacancy.job_title
      click_on I18n.t("publishers.vacancies.show.heading_component.action.copy")

      new_vacancy = Vacancy.all.order(:created_at).last

      expect(current_path).to eq(organisation_job_build_path(new_vacancy.id, :important_dates))
      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_path(new_vacancy.id))
    end
  end

  context "when the original job has expired" do
    let!(:original_vacancy) { create(:vacancy, :expired, organisations: [school]) }

    include_examples "publishing a copied vacancy", type: "expired"
  end
end
