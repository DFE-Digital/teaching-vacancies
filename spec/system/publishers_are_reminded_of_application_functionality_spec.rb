require "rails_helper"

RSpec.describe "Application feature reminder" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:last_vacancy) { Vacancy.order("created_at").last }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  context "when at least one vacancy has been published that accepts applications through TV" do
    let!(:vacancy) { create(:vacancy, :published, enable_job_applications: true, publisher: publisher, organisations: [organisation]) }

    it "does not show reminder page when creating a job" do
      visit organisation_path
      click_on I18n.t("buttons.create_job")
      expect(current_path).to eq(create_or_copy_organisation_jobs_path)
    end
  end

  context "when no vacancy that accepts applications through TV has been published since the last update to the new features page" do
    before { stub_const("Publishers::NewFeaturesController::NEW_FEATURES_PAGE_UPDATED_AT", DateTime.new(2020, 1, 1).freeze) }

    let!(:vacancy) { create(:vacancy, :published, enable_job_applications: false, publisher: publisher, organisations: [organisation]) }

    it "shows reminder page before first step of create job and does not show it twice in the same session" do
      visit organisation_path
      click_on I18n.t("buttons.create_job")
      click_on "Continue"

      expect(page).to have_content(I18n.t("publishers.new_features.reminder.page_title"))
      expect(page).to have_link(I18n.t("application_pack.link_text", size: application_pack_asset_size), href: application_pack_asset_path)

      click_on I18n.t("buttons.reminder_continue")

      expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_role))

      choose find(:css, ".govuk-radios .govuk-radios__item label", match: :first).text
      click_on I18n.t("buttons.continue")

      expect(page).not_to have_content(I18n.t("publishers.new_features.reminder.page_title"))

      visit organisation_path
      click_on I18n.t("buttons.create_job")
      expect(current_path).to eq(create_or_copy_organisation_jobs_path)
    end

    it "does not show reminder page when editing a job" do
      visit organisation_job_path(vacancy.id)

      click_on "Change", match: :first

      expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_role))
    end

    context "when the publisher has seen the new features page during the current session" do
      let(:publisher) { create(:publisher, dismissed_new_features_page_at: nil) }

      it "does not show the reminder page" do
        visit organisation_path
        expect(current_path).to eq(new_features_path)
        check I18n.t("helpers.label.publishers_new_features_form.dismiss_options.true")
        click_on I18n.t("buttons.continue_to_account")
        visit organisation_path
        click_on I18n.t("buttons.create_job")
        expect(current_path).to eq(create_or_copy_organisation_jobs_path)
      end
    end
  end
end
