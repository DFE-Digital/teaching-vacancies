require "rails_helper"

RSpec.describe "Application feature reminder" do
  let(:organisation) { create(:school, name: "A school with a vacancy") }
  let!(:vacancy) { create(:vacancy, :published, enable_job_applications: false, created_at: 1.days.ago, publisher_id: publisher.id, organisations: [organisation]) }
  let(:publisher) { create(:publisher) }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  context "Visiting the school page" do
    context "Create a vacancy" do
      it "Displays application feature reminder" do
        visit organisation_path
        click_on I18n.t("buttons.create_job")

        expect(page).to have_content(I18n.t("jobs.reminder_title"))
        expect(page).to have_link(I18n.t("application_pack.link_text", size: application_pack_asset_size), href: application_pack_asset_path)

        click_on I18n.t("jobs.reminder_continue_button")

        expect(current_path).to eq(organisation_job_build_path(Vacancy.order("created_at").last.id, :job_role))
      end
    end

    context "Edit a vacancy" do
      it "Doesnt display application feature reminder" do
        visit organisation_job_path(vacancy.id)

        click_on "Change", match: :first

        expect(current_path).to eq(organisation_job_build_path(Vacancy.order("created_at").last.id, :job_role))
      end
    end
  end
end
