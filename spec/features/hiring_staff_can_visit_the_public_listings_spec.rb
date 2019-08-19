require 'rails_helper'

RSpec.feature 'School viewing public listings' do
  def set_up_omniauth_config
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
  end

  context 'when the Dfe Sign In Authorisation feature flag is enabled' do
    before do
      allow(DfeSignInAuthorisationFeature).to receive(:enabled?) { true }
      OmniAuth.config.test_mode = true
    end

    after(:each) do
      set_up_omniauth_config
    end

    let!(:school) { create(:school, urn: '110627') }

    context 'when signed in with DfE Sign In' do
      before(:each) do
        stub_accepted_terms_and_condition
        stub_authentication_step(school_urn: '110627')
        stub_authorisation_step
        stub_sign_in_with_multiple_organisations
      end

      scenario 'A signed in school should see a link back to their own dashboard when viewing public listings' do
        visit root_path

        sign_in_user

        link_to_dashboard_is_visible_to_hiring_staff?
      end
    end

    def stub_accepted_terms_and_condition
      create(:user, oid: '161d1f6a-44f1-4a1a-940d-d1088c439da7', accepted_terms_at: 1.day.ago)
    end
  end

  context 'when the Dfe Sign In Authorisation feature flag is disabled' do
    before do
      allow(DfeSignInAuthorisationFeature).to receive(:enabled?) { false }
      OmniAuth.config.test_mode = true
    end

    after(:each) do
      set_up_omniauth_config
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
      end

      scenario 'A signed in school should see a link back to their own dashboard when viewing public listings' do
        visit root_path

        sign_in_user

        link_to_dashboard_is_visible_to_hiring_staff?
      end
    end
  end

  def sign_in_user
    within('.govuk-header__navigation.mobile-header-menu-item') { click_on(I18n.t('nav.sign_in')) }
    click_on(I18n.t('sign_in.link'))
  end

  def link_to_dashboard_is_visible_to_hiring_staff?
    expect(page).to have_content("Jobs at #{school.name}")
    within('.govuk-header__navigation') { expect(page).to have_content(I18n.t('nav.school_page_link')) }

    click_on(I18n.t('app.title'))
    expect(page).to have_content(I18n.t('jobs.heading'))

    click_on(I18n.t('nav.school_page_link'))
    expect(page).to have_content("Jobs at #{school.name}")
  end
end
