require "rails_helper"

RSpec.describe "Sub navigation for users to sign in and out" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let!(:publisher) { create(:publisher, organisations: [organisation]) }

  context "when user is not signed in" do
    before { visit root_path }

    it "renders the correct links" do
      within ".sub-navigation" do
        expect(page).to have_content(I18n.t("sub_nav.jobs"))
        expect(page).to have_content(I18n.t("sub_nav.schools"))
      end
    end
  end

  context "when jobseeker is signed in" do
    before do
      login_as(jobseeker, scope: :jobseeker)
      visit root_path
    end

    it "renders the correct links" do
      within ".sub-navigation" do
        expect(page).to have_content(I18n.t("sub_nav.jobs"))
        expect(page).to have_content(I18n.t("sub_nav.schools"))
        expect(page).to have_content(I18n.t("sub_nav.jobseekers.applications"))
        expect(page).to have_content(I18n.t("sub_nav.jobseekers.job_alerts"))
        expect(page).to have_content(I18n.t("sub_nav.jobseekers.saved_jobs"))
      end
    end
  end

  context "when publisher is signed in" do
    before do
      login_publisher(publisher: publisher, organisation: organisation)
      visit root_path
    end

    it "does not render the subnav" do
      expect(page).not_to have_css(".sub-navigation")
    end
  end
end
