require "rails_helper"

RSpec.describe "Jobseekers can view their dashboard" do
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com") }
  let(:jobseeker_applications_enabled?) { false }
  let(:accounts_page) { PageObjects::Jobseekers::Account.new }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(jobseeker_applications_enabled?)
    login_as(jobseeker, scope: :jobseeker)
    accounts_page.load
  end

  it "shows their email in the dashboard header" do
    expect(accounts_page.dashboard_header.email).to have_content("jobseeker@example.com")
  end

  context "when JobseekerApplicationsFeature is enabled" do
    let(:jobseeker_applications_enabled?) { true }

    it "shows `My applications` tab" do
      expect(accounts_page.dashboard_header.nav.links(text: I18n.t("jobseekers.job_applications.index.page_title"))).not_to be_blank
    end
  end

  context "when JobseekerApplicationsFeature is enabled" do
    it "does not show `My applications` tab" do
      expect(accounts_page.dashboard_header.nav.links(text: I18n.t("jobseekers.job_applications.index.page_title"))).to be_blank
    end
  end
end
