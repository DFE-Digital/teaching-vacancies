require 'rails_helper'

RSpec.feature 'Hiring staff session' do
  let(:school) { create(:school) }
  let(:session_id) { 'session_id' }
  let(:current_user) { User.find_by(oid: session_id) }
  before do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  after do
    travel_back
  end

  it 'expires after 8 hours and redirects to login page' do
    visit new_school_job_path

    travel 9.hours do
      click_on I18n.t('buttons.save_and_continue')

      expect(page.current_path).to eq new_identifications_path
    end
  end

  it 'doesn\'t expire before 8 hours' do
    visit new_school_job_path

    travel 1.hour do
      click_on I18n.t('buttons.save_and_continue')

      expect(page.current_path).to eq job_specification_school_job_path
    end
  end
end
