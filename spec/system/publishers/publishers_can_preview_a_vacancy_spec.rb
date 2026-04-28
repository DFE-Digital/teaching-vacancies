require "rails_helper"

RSpec.describe "Publishers can preview a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }
  let(:vacancy) { create(:draft_vacancy, :secondary, :ect_suitable, job_roles: ["teacher"], organisations: [school]) }

  before { login_publisher(publisher: publisher, organisation: school) }

  after { logout }

  context "when reviewing a draft vacancy" do
    before do
      visit organisation_job_preview_path(vacancy.id)
      # wait for page load
      find("span.govuk-caption-l")
      find("footer")
    end

    it "passes a11y", :a11y do
      expect(page).to be_axe_clean
    end

    context "when the job has been scheduled" do
      let(:vacancy) { create(:vacancy, :secondary, :future_publish, :ect_suitable, job_roles: %w[teacher other_support], organisations: [school]) }

      scenario "users can preview the listing" do
        expect(page).to have_current_path(organisation_job_preview_path(vacancy.id))
        verify_vacancy_show_page_details(vacancy)
      end
    end

    context "when the job in draft and all steps are valid" do
      let(:vacancy) { create(:vacancy, :secondary, :future_publish, :ect_suitable, job_roles: %w[teacher other_support], organisations: [school]) }

      scenario "users can preview the listing" do
        expect(page).to have_current_path(organisation_job_preview_path(vacancy.id))
        verify_vacancy_show_page_details(vacancy)
      end
    end
  end
end
