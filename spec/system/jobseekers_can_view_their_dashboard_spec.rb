require "rails_helper"

RSpec.describe "Jobseekers can view their dashboard" do
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@example.com") }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_account_path
  end

  it "shows their email in the dashboard header" do
    expect(page).to have_css(".tabs-component") do |dashboard|
      expect(dashboard).to have_css("h2", text: "jobseeker@example.com")
    end
  end

  it "shows `Applications` tab" do
    expect(page).to have_css(".tabs-component") do |dashboard|
      expect(dashboard).to have_css(".tabs-component-navigation__list") do |nav|
        expect(nav).to have_link(I18n.t("jobseekers.job_applications.index.page_title"))
      end
    end
  end
end
