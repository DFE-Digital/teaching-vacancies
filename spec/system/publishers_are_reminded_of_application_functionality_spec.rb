require "rails_helper"

RSpec.describe "Application feature reminder" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:last_vacancy) { Vacancy.order("created_at").last }

  before { login_publisher(publisher: publisher, organisation: organisation, allow_reminders: true) }

  context "when at least one vacancy has been published that accepts applications through TV" do
    let!(:vacancy) { create(:vacancy, :published, enable_job_applications: true, publisher: publisher, organisations: [organisation]) }

    it "does not show reminder page when creating a job" do
      visit organisation_jobs_with_type_path
      click_on I18n.t("buttons.create_job")
      expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_role))
    end
  end

  context "when no vacancy that accepts applications through TV has been published since the last update to the new features page" do
    before { stub_const("Publishers::NewFeaturesController::NEW_FEATURES_PAGE_UPDATED_AT", DateTime.new(2020, 1, 1).freeze) }

    let!(:vacancy) { create(:vacancy, :published, enable_job_applications: false, publisher: publisher, organisations: [organisation]) }

    it "shows reminder page before first step of create job and does not show it twice in the same session" do
      visit organisation_jobs_with_type_path
      click_on I18n.t("buttons.create_job")

      expect(page).to have_content(I18n.t("publishers.new_features.reminder.page_title"))
      expect(page).to have_link(I18n.t("publishers.new_features.reminder.how_applications_work_link"), href: post_path(section: "get-help-hiring", post_name: "accepting-job-applications-on-teaching-vacancies"))

      click_on I18n.t("buttons.reminder_continue")

      expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_role))

      expect(page).not_to have_content(I18n.t("publishers.new_features.reminder.page_title"))

      visit organisation_jobs_with_type_path
      click_on I18n.t("buttons.create_job")
      expect(current_path).to eq(organisation_job_build_path(Vacancy.order("created_at").last.id, :job_role))
    end

    it "does not show reminder page when editing a job" do
      visit organisation_job_path(vacancy.id)

      click_on "Change", match: :first

      expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_role))
    end

    # TODO: Temporarily disabled for TEVA-4099
    xcontext "when the publisher has seen the new features page during the current session" do
      let(:publisher) { create(:publisher, dismissed_new_features_page_at: nil) }

      it "does not show the reminder page" do
        visit organisation_jobs_with_type_path
        expect(current_path).to eq(publishers_new_features_path)
        check I18n.t("helpers.label.publishers_new_features_form.dismiss_options.true")
        click_on I18n.t("buttons.continue_to_account")
        visit organisation_jobs_with_type_path
        click_on I18n.t("buttons.create_job")
        expect(current_path).to eq(organisation_jobs_path)
      end
    end
  end
end
