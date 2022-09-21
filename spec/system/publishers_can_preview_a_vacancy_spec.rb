require "rails_helper"

RSpec.describe "Publishers can preview a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }
  let(:vacancy) { create(:vacancy, :draft, :teacher, :ect_suitable, organisations: [school], phases: %w[secondary], key_stages: %w[ks3]) }

  before { login_publisher(publisher: publisher, organisation: school) }

  context "when reviewing a draft vacancy" do
    before { visit organisation_job_path(vacancy.id) }

    context "when the job has been scheduled" do
      let(:vacancy) { create(:vacancy, :future_publish, :teacher, :ect_suitable, organisations: [school], phases: %w[secondary], key_stages: %w[ks3]) }

      scenario "users can preview the listing" do
        click_on I18n.t("publishers.vacancies.show.heading_component.action.preview")

        expect(page).to have_current_path(organisation_job_preview_path(vacancy.id))
        verify_vacancy_show_page_details(vacancy)
      end
    end

    context "when the job in draft and all steps are valid" do
      let(:vacancy) { create(:vacancy, :future_publish, :teacher, :ect_suitable, organisations: [school], phases: %w[secondary], key_stages: %w[ks3]) }

      scenario "users can preview the listing" do
        click_on I18n.t("publishers.vacancies.show.heading_component.action.preview")

        expect(page).to have_current_path(organisation_job_preview_path(vacancy.id))
        verify_vacancy_show_page_details(vacancy)
      end
    end
  end
end
