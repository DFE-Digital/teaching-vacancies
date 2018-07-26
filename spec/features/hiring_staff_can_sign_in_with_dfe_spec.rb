require 'rails_helper'
RSpec.feature 'Hiring staff signing-in with DfE Sign In' do
  before do
    OmniAuth.config.test_mode = true
    ENV['SIGN_IN_WITH_DFE'] = 'true'
  end

  after(:each) do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    ENV['SIGN_IN_WITH_DFE'] = 'false'
  end

  let!(:school) { create(:school, urn: '110627') }

  context 'with valid credentials that do match a school' do
    before(:each) do
      OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
        provider: 'dfe',
        uid: 'an-unknown-oid',
        info: {
          email: 'an-email@example.com',
        }
      )

      mock_response = double(code: '200', body: {
        user:
        {
          permissions:
          [
            {
              user_token: 'an-email@example.com',
              school_urn: '110627'
            }
          ]
        }
      }.to_json)

      expect(TeacherVacancyAuthorisation::Permissions).to receive(:new)
        .and_return(AuthHelpers::MockPermissions.new(mock_response))
      visit root_path
      click_on(I18n.t('nav.sign_in'))
      choose(HiringStaff::IdentificationsController::DFE_SIGN_IN_OPTIONS.first.to_radio.last)
      click_on(I18n.t('sign_in.link'))
    end

    scenario 'it signs in the user successfully' do
      expect(page).to have_content("Jobs at #{school.name}")
      within('#proposition-links') { expect(page).to have_content(I18n.t('nav.sign_out')) }
      within('#proposition-links') { expect(page).to have_content(I18n.t('nav.school_page_link')) }
    end

    scenario 'adds entries in the audit log' do
      activity = PublicActivity::Activity.last
      expect(activity.key).to eq('dfe-sign-in.authorisation.success')
      expect(activity.trackable.urn).to eq(school.urn)

      authorisation = PublicActivity::Activity.last
      expect(authorisation.key).to eq('dfe-sign-in.authorisation.success')
      expect(authorisation.trackable.urn).to eq(school.urn)
    end
  end

  context 'with valid credentials that do not match a school' do
    before(:each) do
      OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
        provider: 'dfe',
        uid: 'an-unknown-oid',
        info: {
          email: 'another_email@example.com',
        }
      )
      mock_response = double(code: '200', body: { user: { permissions: [] } }.to_json)
      expect(TeacherVacancyAuthorisation::Permissions).to receive(:new)
        .and_return(AuthHelpers::MockPermissions.new(mock_response))

      visit root_path
      click_on(I18n.t('nav.sign_in'))
      choose(HiringStaff::IdentificationsController::DFE_SIGN_IN_OPTIONS.first.to_radio.last)
      click_on(I18n.t('sign_in.link'))
    end

    scenario 'it does not sign-in the user' do
      expect(page).to have_content(I18n.t('static_pages.not_authorised.title'))
      within('#proposition-links') { expect(page).not_to have_content(I18n.t('nav.school_page_link')) }
    end

    scenario 'adds entries in the audit log' do
      authentication = PublicActivity::Activity.first
      expect(authentication.key).to eq('dfe-sign-in.authentication.success')

      authorisation = PublicActivity::Activity.last
      expect(authorisation.key).to eq('dfe-sign-in.authorisation.failure')
    end
  end
end
