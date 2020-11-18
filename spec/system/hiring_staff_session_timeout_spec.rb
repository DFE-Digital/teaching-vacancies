require "rails_helper"

RSpec.describe "Hiring staff session" do
  let(:school) { create(:school) }
  let(:session_id) { "session_id" }
  let(:current_user) { User.find_by(oid: session_id) }
  before do
    allow(AuthenticationFallback).to receive(:enabled?).and_return(false)
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  after do
    travel_back
  end

  it "expires after TIMEOUT_PERIOD and redirects to login page" do
    visit organisation_path
    click_on I18n.t("buttons.create_job")

    travel(HiringStaff::BaseController::TIMEOUT_PERIOD + 1.minute) do
      click_on I18n.t("buttons.continue")

      sign_out_via_dsi

      expect(page).to have_content("signed out")
      expect(page).to have_content("inactive")
    end
  end

  it "doesn't expire before TIMEOUT_PERIOD" do
    visit organisation_path
    click_on I18n.t("buttons.create_job")

    travel(HiringStaff::BaseController::TIMEOUT_PERIOD - 1.minute) do
      click_on I18n.t("buttons.continue")

      expect(page.current_path).to eq organisation_job_build_path(Vacancy.last.id, :job_details)
    end
  end
end
