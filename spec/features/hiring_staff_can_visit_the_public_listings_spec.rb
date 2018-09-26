require 'rails_helper'

RSpec.feature 'School viewing public listings' do
  before do
    OmniAuth.config.test_mode = true
  end

  after(:each) do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
  end

  let!(:school) { create(:school, urn: '110627') }
  let!(:user) { create(:user, oid: 'a-valid-oid') }

  context 'when signed in with DfE Sign In' do
    before(:each) do
      OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
        provider: 'dfe',
        uid: 'a-valid-oid',
        info: {
          email: 'an-email@example.com',
        },
        extra: {
          raw_info: {
            organisation: { urn: '110627' }
          }
        }
      )

      mock_response = double(code: '200', body: { user: { permissions: [{ school_urn: '110627' }] } }.to_json)
      allow(TeacherVacancyAuthorisation::Permissions).to receive(:new)
        .and_return(AuthHelpers::MockPermissions.new(mock_response))

      ENV['SIGN_IN_WITH_DFE'] = 'true'
    end

    after(:each) do
      ENV['SIGN_IN_WITH_DFE'] = 'false'
    end

    scenario 'A signed in school should see a link back to their own dashboard when viewing public listings' do
      visit root_path

      click_on(I18n.t('nav.sign_in'))
      click_on(I18n.t('sign_in.link'))

      expect(page).to have_content("Jobs at #{school.name}")
      within('.govuk-header__navigation') { expect(page).to have_content(I18n.t('nav.school_page_link')) }

      click_on(I18n.t('app.title'))
      expect(page).to have_content(I18n.t('jobs.heading'))

      click_on(I18n.t('nav.school_page_link'))
      expect(page).to have_content("Jobs at #{school.name}")
    end
  end
end
