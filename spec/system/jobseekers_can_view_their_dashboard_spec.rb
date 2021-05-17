require "rails_helper"

RSpec.describe "Jobseekers can view their dashboard" do
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com") }
  let(:jobseeker_applications_enabled?) { false }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(jobseeker_applications_enabled?)
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_account_path
  end

  it "shows their email in the dashboard header" do
    expect(page).to have_css(".dashboard-component") do |dashboard|
      expect(dashboard).to have_css("h2", text: "jobseeker@example.com")
    end
  end

  context "when JobseekerApplicationsFeature is enabled" do
    let(:jobseeker_applications_enabled?) { true }

    it "shows `My applications` tab" do
      expect(page).to have_css(".dashboard-component") do |dashboard|
        expect(dashboard).to have_css(".dashboard-component-navigation__list") do |nav|
          expect(nav).to have_link(I18n.t("jobseekers.job_applications.index.page_title"))
        end
      end
    end
  end

  context "when JobseekerApplicationsFeature is enabled" do
    it "does not show `My applications` tab" do
      expect(page).to have_css(".dashboard-component") do |dashboard|
        expect(dashboard).to have_css(".dashboard-component-navigation__list") do |nav|
          expect(nav).not_to have_link(I18n.t("jobseekers.job_applications.index.page_title"))
        end
      end
    end
  end
end
