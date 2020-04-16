require 'rails_helper'

RSpec.feature 'Hiring staff accepts terms and conditions' do
  let(:school) { create(:school) }
  let(:session_id) { 'a-valid-oid' }
  let(:current_user) { User.find_by(oid: session_id) }
  before do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  context 'the user has not accepted the terms and conditions' do
    before { current_user.update(accepted_terms_at: nil) }

    scenario 'they will see the terms and conditions' do
      visit school_path

      expect(page).to have_content(I18n.t('terms_and_conditions.please_accept'))
    end

    scenario 'they can accept the terms and conditions' do
      visit terms_and_conditions_path

      expect(current_user).not_to be_accepted_terms_and_conditions

      check I18n.t('terms_and_conditions.label')
      click_on I18n.t('buttons.accept_and_continue')

      current_user.reload
      expect(page).to have_content(I18n.t('schools.jobs.index', school: school.name))
      expect(current_user).to be_accepted_terms_and_conditions
    end

    scenario 'an audit entry is logged when they accept' do
      visit terms_and_conditions_path

      expect(current_user).not_to be_accepted_terms_and_conditions

      check I18n.t('terms_and_conditions.label')
      click_on I18n.t('buttons.accept_and_continue')

      activity = current_user.activities.last
      expect(activity.key).to eq('user.terms_and_conditions.accept')
      expect(activity.session_id).to eq(session_id)
    end

    scenario 'an error is shown if they don’t accept' do
      visit terms_and_conditions_path

      expect(current_user).not_to be_accepted_terms_and_conditions

      click_on I18n.t('buttons.accept_and_continue')

      current_user.reload

      expect(page).to have_content(I18n.t('jobs.errors_present'))
      expect(current_user).not_to be_accepted_terms_and_conditions
    end

    scenario 'can sign out' do
      visit terms_and_conditions_path
      click_on(I18n.t('nav.sign_out'))
      # A request to logout is sent to DfE Sign-in system. On success DSI comes back at auth_dfe_signout_path
      visit auth_dfe_signout_path

      expect(page).to have_content(I18n.t('messages.access.signed_out'))
    end
  end

  context 'the user has accepted the terms and conditions' do
    scenario 'they will not see the terms and conditions' do
      current_user.update(accepted_terms_at: Time.zone.now)

      visit school_path

      expect(page).not_to have_content(I18n.t('terms_and_conditions.please_accept'))
    end
  end
end
