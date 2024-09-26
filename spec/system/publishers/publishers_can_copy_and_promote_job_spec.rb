require "rails_helper"

RSpec.describe "Publishers can copy and promote job" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :draft, organisations: [organisation], publisher: publisher, publish_on: publish_on) }
  let(:share_page_content) { I18n.t("publishers.vacancies.summary.share_page_url") }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_job_review_path(vacancy.id)
  end

  after do
    logout
  end

  context "when the vacancy is published today" do
    let(:publish_on) { Date.current }

    it "shows the share link" do
      click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
      expect(page).to have_content(share_page_content)
    end
  end

  context "when the vacancy is published tomorrow" do
    let(:publish_on) { Date.tomorrow }

    it "doesnt show the share link" do
      click_on I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft")
      expect(page).not_to have_content(share_page_content)
    end
  end
end
