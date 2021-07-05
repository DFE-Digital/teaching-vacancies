require "rails_helper"

RSpec.describe "Publishers can share their vacancy" do
  let(:school) { create(:school) }
  let(:publisher) { create(:publisher, organisation_publishers_attributes: [{ organisation: school }]) }
  let!(:vacancy) { create(:vacancy, :published, organisation_vacancies_attributes: [{ organisation: school }]) }

  before { login_publisher(publisher: publisher, organisation: school) }

  scenario "A school can visit their page as the jobseeker would" do
    visit organisation_path

    click_on(vacancy.job_title)
    click_on(I18n.t("publishers.vacancies.show.view_live_listing_link"))
    expect(current_path).to match(job_path(vacancy))
  end
end
