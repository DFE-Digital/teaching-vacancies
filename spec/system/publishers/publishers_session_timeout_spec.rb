require "rails_helper"

RSpec.describe "Publisher session" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  before do
    allow(AuthenticationFallback).to receive(:enabled?).and_return(false)
    login_publisher(publisher: publisher, organisation: school)
  end

  after { logout }

  it "expires after TIMEOUT_PERIOD and redirects to login page" do
    visit organisation_jobs_with_type_path
    click_on I18n.t("buttons.create_job")
    expect(current_path).to eq(organisation_jobs_start_path)
    click_on I18n.t("buttons.create_job")

    travel(Publisher.timeout_in + 1.minute) do
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content(I18n.t("devise.failure.timeout"))
      visit "/"
      expect(page).not_to have_content(I18n.t("devise.failure.timeout"))
    end
  end

  it "doesn't expire before TIMEOUT_PERIOD" do
    visit organisation_jobs_with_type_path
    click_on I18n.t("buttons.create_job")
    expect(current_path).to eq(organisation_jobs_start_path)
    click_on I18n.t("buttons.create_job")

    travel(Publisher.timeout_in - 1.minute) do
      click_on I18n.t("buttons.save_and_continue")

      expect(page.current_path).to eq organisation_job_build_path(Vacancy.last.id, :job_title)
    end
  end
end
