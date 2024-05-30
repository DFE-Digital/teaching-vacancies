require "rails_helper"

RSpec.describe "Jobseekers can apply for a vacancy" do
  let(:vacancy) do
    create(:vacancy, :published, :no_tv_applications,
           application_link: "www.google.com", organisations: [build(:school)])
  end

  before { visit job_path(vacancy) }

  scenario "the application link is without protocol" do
    expect(page).to have_link(I18n.t("jobs.apply", href: "http://www.google.com"))
  end

  let(:expired_vacancy) do
    create(:vacancy, :expired, :no_tv_applications,
           application_link: "www.google.com", organisations: [build(:school)])
  end

  scenario "the application links are not present for expired vacancy" do
    visit job_path(expired_vacancy)
    expect(page).not_to have_link(I18n.t("jobs.apply", href: "http://www.google.com"))
  end
end
