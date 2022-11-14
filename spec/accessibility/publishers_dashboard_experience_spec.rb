require "rails_helper"

RSpec.describe "Publisher dashboard experience", type: :system, accessibility: true do
  let(:organisation) { create(:school, name: "A school with a vacancy") }
  let(:publisher) { create(:publisher) }
  let(:vacancy) { create(:vacancy, :published, organisations: [organisation]) }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  context "Publisher visits the vacancy dashboard page" do
    before do
      create_list(:vacancy, 5, :published, organisations: [organisation])
      visit organisation_path
    end

    it "it meets accessibility standards" do
      expect(page).to meet_accessibility_standards
    end
  end

  context "Publisher visits the manage applications page" do
    let!(:job_application_submitted) { create(:job_application, :status_submitted, vacancy: vacancy) }

    before { visit organisation_job_job_applications_path(vacancy.id) }

    it "it meets accessibility standards" do
      expect(page).to meet_accessibility_standards
    end
  end
end
