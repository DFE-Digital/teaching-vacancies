require "rails_helper"

RSpec.describe "Application feature reminder" do
  let(:organisation) { create(:school, name: "A school with a vacancy") }
  let!(:vacancy) { create(:vacancy, :published, enable_job_applications: false, created_at: 1.days.ago, publisher_id: publisher.id, organisations: [organisation]) }
  let(:publisher) { create(:publisher, viewed_application_feature_reminder_page_at: nil) }
  let(:last_vacancy) { Vacancy.order("created_at").last }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  context "when creating a vacancy" do
    it "displays application feature reminder before first build step" do
      visit organisation_path
      click_on I18n.t("buttons.create_job")

      expect(page).to have_content(I18n.t("jobs.reminder_title"))
      expect(page).to have_link(I18n.t("application_pack.link_text", size: application_pack_asset_size), href: application_pack_asset_path)

      click_on I18n.t("jobs.reminder_continue_button")

      expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_role))

      choose find(:css, ".govuk-radios .govuk-radios__item label", match: :first).text
      click_on I18n.t("buttons.continue")

      expect(page).not_to have_content(I18n.t("jobs.reminder_title"))
    end
  end

  context "when editing a vacancy" do
    it "doesnt display application feature reminder" do
      visit organisation_job_path(vacancy.id)

      click_on "Change", match: :first

      expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_role))
    end
  end
end
