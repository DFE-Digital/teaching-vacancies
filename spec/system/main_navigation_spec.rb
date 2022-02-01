require "rails_helper"

RSpec.describe "Main navigation for users to sign in and out" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }
  let!(:publisher) { create(:publisher, organisations: [organisation]) }

  context "when user is not signed in" do
    before { visit root_path }

    it "renders the correct links" do
      within "nav" do
        expect(page).to have_content(I18n.t("nav.create_a_job_alert"))
        expect(page).to have_content(I18n.t("buttons.sign_in"))
      end
    end
  end

  context "when jobseeker is signed in" do
    before do
      login_as(jobseeker, scope: :jobseeker)
      visit root_path
    end

    it "renders the correct links" do
      within "nav" do
        expect(page).to have_content(I18n.t("nav.find_job"))
        expect(page).to have_content(I18n.t("footer.your_account"))
        expect(page).to have_content(I18n.t("nav.sign_out"))
      end
    end
  end

  context "when publisher is signed in" do
    before do
      login_publisher(publisher: publisher, organisation: organisation)
      visit root_path
    end

    it "renders the correct links" do
      within "nav" do
        expect(page).to have_content(I18n.t("nav.school_page_link"))
        expect(page).to have_content(I18n.t("nav.jobseekers_index_link"))
        expect(page).to have_content(I18n.t("nav.notifications_index_link_html", count: 0))
        expect(page).to have_content(I18n.t("nav.sign_out"))
      end
    end
  end
end
