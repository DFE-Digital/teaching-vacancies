require "rails_helper"

RSpec.describe "Publishers fill out pre-employement checks" do
  let(:publisher) { create(:publisher, email: "publisher@contoso.com") }
  let(:job_application) { create(:job_application, :status_offered, vacancy: vacancy) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [school], publisher: publisher) }
  let(:school) { create(:school) }

  before do
    login_publisher(publisher: publisher, organisation: school)
    publisher_ats_pre_interview_checks_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
    click_on "Pre-employment checklist"
  end

  after { logout }

  context "without an existing record" do
    it "can create a pre employment check set" do
      check "Verified identity"
      click_on "Save and update checklist"
      expect(job_application.pre_employment_check_set).to have_attributes(identity_check: true)
    end
  end

  context "with an existing record" do
    before do
      create(:pre_employment_check_set, job_application: job_application, identity_check: true)
      visit current_path
    end

    it "can select and de-select pre-employment checks" do
      check "Enhanced DBS Check"
      uncheck "Verified identity"
      click_on "Save and update checklist"
      expect(job_application.pre_employment_check_set.reload).to have_attributes(identity_check: false, enhanced_dbs_check: true)
    end
  end
end
