require 'rails_helper'

RSpec.feature 'Hiring staff session' do
  let(:school) { create(:school) }
  let(:session_id) { 'session_id' }
  let(:current_user) { User.find_by(oid: session_id) }
  before do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  after do
    Timecop.return
  end

  def keep_user_active(length_of_time, path: new_school_job_path)
    time_between_visits = HiringStaff::BaseController::TIMEOUT_PERIOD / 2
    number_of_times_to_visit = length_of_time / time_between_visits

    number_of_times_to_visit.times do
      visit path
      Timecop.travel(time_between_visits)
    end
  end

  # TODO: add tests for TIMEOUT_PERIOD sign out

  it 'expires after inactivity and redirects to login page' do
    dsi_signout_path = '/session/end'

    visit new_school_job_path

    Timecop.travel(HiringStaff::BaseController::TIMEOUT_PERIOD + 1.second)

    click_on I18n.t('buttons.save_and_continue')

    expect(page.current_path).to eq dsi_signout_path

    # A request to logout is sent to DfE Sign-in system. On success DSI comes back at auth_dfe_signout_path
    visit auth_dfe_signout_path

    expect(page.current_path).to eq new_identifications_path

    within('.govuk-header__navigation') { expect(page).to have_content(I18n.t('nav.sign_in')) }
    expect(page).to have_content(I18n.t('messages.access.signed_out_for_inactivity'))
  end

  it 'doesn\'t expire while user is active' do
    visit new_school_job_path

    keep_user_active(10.hours)

    click_on I18n.t('buttons.save_and_continue')

    expect(page.current_path).to eq job_specification_school_job_path
  end
end
