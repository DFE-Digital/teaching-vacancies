require "rails_helper"
RSpec.describe "Application meta tags" do
  context "when visiting the service start page" do
    scenario "meta tags are present" do
      visit root_path
      expect(page.find('meta[name="description"]', visible: false)).to be_present
    end
  end

  context "when viewing an expired vacancy" do
    let(:organisation) { create(:school) }
    let(:expired_vacancy) { create(:vacancy, :expired, organisations: [organisation]) }

    scenario "the correct meta tag is present" do
      visit job_path(expired_vacancy)

      expect(page.find('meta[content="noindex"]', visible: false)).to be_present
    end
  end
end
