require "rails_helper"

RSpec.describe "Application feature reminder" do
  let(:organisation) { create(:school, name: "A school with a vacancy") }
  let(:publisher) { create(:publisher) }
  let(:last_vacancy) { Vacancy.order("created_at").last }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  context "when publisher has not seen the new features page" do
    before { publisher.viewed_application_feature_reminder_page_at = nil }
    it "visiting create job link does not show reminder" do
      visit organisation_path
      click_on I18n.t("buttons.create_job")
      expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_role))
    end
  end

  context "when publisher has seen the new features page" do
    before { publisher.viewed_application_feature_reminder_page_at = 1.days.ago }
    context "when there are vacancies published since that accept applications through teacher vacancies" do
      let!(:vacancy) { create(:vacancy, :published, enable_job_applications: true, created_at: Time.now, publisher: publisher, organisations: [organisation]) }

      it "visiting create job link does not show reminder page" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")
        expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_role))
      end
    end

    context "when there are vacancies published since that do not accept applications through teacher vacancies" do
      let!(:vacancy) { create(:vacancy, :published, enable_job_applications: false, created_at: Time.now, publisher: publisher, organisations: [organisation]) }

      it "visiting create job link does show reminder page before first step" do
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

      it "visiting edit job pages does not show reminder page" do
        visit organisation_job_path(vacancy.id)

        click_on "Change", match: :first

        expect(current_path).to eq(organisation_job_build_path(last_vacancy.id, :job_role))
      end
    end
  end
end
