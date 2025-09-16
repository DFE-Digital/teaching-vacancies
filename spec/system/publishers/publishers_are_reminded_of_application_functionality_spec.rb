require "rails_helper"

RSpec.describe "Application feature reminder" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:last_vacancy) { DraftVacancy.order(:created_at).last }

  before do
    login_publisher(publisher:, organisation:, allow_reminders: true)
    visit organisation_jobs_with_type_path
    click_on I18n.t("buttons.create_job")
  end

  after { logout }

  context "when at least one vacancy has been published that accepts applications through TV" do
    let!(:vacancy) { create(:vacancy, enable_job_applications: true, publisher:, organisations: [organisation]) }

    it "does not show reminder page when creating a job" do
      expect(current_path).to eq(organisation_jobs_start_path)
      click_on I18n.t("buttons.create_job")
      expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_title))
    end
  end

  context "when no vacancy that accepts applications through TV has been published since the last update to the new features page" do
    before { stub_const("Publishers::NewFeaturesController::NEW_FEATURES_PAGE_UPDATED_AT", DateTime.new(2020, 1, 1).freeze) }

    let!(:vacancy) { create(:vacancy, enable_job_applications: false, publisher:, organisations: [organisation]) }

    it "shows reminder page before first step of create job and does not show it twice in the same session" do
      expect(current_path).to eq(organisation_jobs_start_path)
      click_on I18n.t("buttons.create_job")
      expect(page).to have_content(I18n.t("publishers.new_features.reminder.page_title"))
      expect(page).to have_link(I18n.t("publishers.new_features.reminder.how_applications_work_link"), href: post_path(section: "get-help-hiring", subcategory: "how-to-create-job-listings-and-accept-applications", post_name: "accepting-job-applications-on-teaching-vacancies"))

      click_on I18n.t("buttons.reminder_continue")

      expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_title))

      expect(page).not_to have_content(I18n.t("publishers.new_features.reminder.page_title"))

      visit organisation_jobs_with_type_path
      click_on I18n.t("buttons.create_job")
      expect(current_path).to eq(organisation_jobs_start_path)
    end

    context "when editing a job" do
      let(:last_vacancy) { PublishedVacancy.order(:created_at).last }

      it "does not show reminder page" do
        expect(current_path).to eq(organisation_jobs_start_path)
        click_on I18n.t("buttons.create_job")
        visit organisation_job_path(vacancy.id)

        click_on "Change", match: :first

        expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_title))
      end
    end
  end
end
