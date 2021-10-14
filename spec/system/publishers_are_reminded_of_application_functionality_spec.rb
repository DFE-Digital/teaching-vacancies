require "rails_helper"

RSpec.describe "Application feature reminder" do
  let(:organisation) { create(:school, name: "A school with a vacancy") }
  let!(:vacancy) { create(:vacancy, :published, enable_job_applications: false, created_at: 1.days.ago, publisher_id: publisher.id) }
  let(:publisher) { create(:publisher, viewed_new_features_page_at: 2.days.ago) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    vacancy.organisation_vacancies.create(organisation: organisation)
    visit organisation_path
  end

  context "Visiting the school page" do
    context "Create a vacancy" do
      it "Displays application feature reminder" do
        click_on I18n.t("buttons.create_job")

        expect(page).to have_content(I18n.t("jobs.reminder_title"))
        expect(page).to have_link(I18n.t("application_pack.link_text", size: application_pack_asset_size), href: application_pack_asset_path)

        click_on I18n.t("jobs.reminder_continue_button")

        expect(current_path).to eq(organisation_job_build_path(Vacancy.order("created_at").last.id, :job_role))
      end
    end
  end
end
