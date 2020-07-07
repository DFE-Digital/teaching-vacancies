require 'rails_helper'

RSpec.feature 'Hiring staff session' do
  let(:school) { create(:school) }
  let(:session_id) { 'session_id' }
  let(:current_user) { User.find_by(oid: session_id) }
  before do
    allow(AuthenticationFallback).to receive(:enabled?).and_return(false)
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  after do
    travel_back
  end

  it 'expires after TIMEOUT_PERIOD and redirects to login page' do
    visit new_organisation_job_path

    travel (HiringStaff::BaseController::TIMEOUT_PERIOD + 1.minute) do
      click_on I18n.t('buttons.continue')

      # A request to logout is sent to DfE Sign-in system. On success DSI comes back at auth_dfe_signout_path
      expect(page.current_url).to include "#{ENV['DFE_SIGN_IN_ISSUER']}/session/end"
      expect(page.current_url).to include CGI.escape(auth_dfe_signout_url)
      visit auth_dfe_signout_path

      expect(page).to have_content('signed out')
      expect(page).to have_content('inactive')
    end
  end

  it 'doesn\'t expire before TIMEOUT_PERIOD' do
    visit new_organisation_job_path

    travel (HiringStaff::BaseController::TIMEOUT_PERIOD - 1.minute) do
      click_on I18n.t('buttons.continue')

      expect(page.current_path).to eq job_specification_organisation_job_path
    end
  end
end
