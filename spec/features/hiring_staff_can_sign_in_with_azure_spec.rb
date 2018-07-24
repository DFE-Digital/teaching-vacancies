require 'rails_helper'
RSpec.feature 'Hiring staff signing-in with Azure' do
  before do
    OmniAuth.config.test_mode = true
  end

  after(:each) do
    OmniAuth.config.mock_auth[:default] = nil
  end

  let!(:school) { create(:school, urn: '110627') }

  context 'with valid credentials that do match a school' do
    before(:each) do
      OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(
        provider: 'default',
        info: {
          name: 'an-email@example.com',
        },
        extra: {
          raw_info: {
            id_token_claims: {
              oid: 'a-valid-oid'
            }
          }
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
      choose(HiringStaff::IdentificationsController::AZURE_SIGN_IN_OPTIONS.first.to_radio.last)
      click_on(I18n.t('sign_in.link'))
    end

    scenario 'signs-in the user successfully' do
      expect(page).to have_content("Jobs at #{school.name}")
      within('#proposition-links') { expect(page).to have_content(I18n.t('nav.sign_out')) }
      within('#proposition-links') { expect(page).to have_content(I18n.t('nav.school_page_link')) }
      within('#proposition-links') { expect(page).to have_selector('a.active', text: 'My jobs') }
    end

    scenario 'adds entries in the audit log' do
      authentication = PublicActivity::Activity.first
      expect(authentication.key).to eq('azure.authentication.success')

      authorisation = PublicActivity::Activity.last
      expect(authorisation.key).to eq('azure.authorisation.success')
      expect(authorisation.trackable.urn).to eq(school.urn)
    end
  end

  context 'with valid credentials that match multiple schools' do
    let!(:other_school) { create(:school, urn: '318937', name: 'Hogwards Academy') }
    let(:mock_response) do
      double(code: '200', body: {
        user:
        {
          permissions:
          [
            {
              user_token: 'an-email@example.com',
              school_urn: '110627'
            },
            {
              user_token: 'an-email@example.com',
              school_urn: '318937'
            }
          ]
        }
      }.to_json)
    end

    before(:each) do
      OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(
        provider: 'default',
        info: {
          name: 'an-email@example.com',
        },
        extra: {
          raw_info: {
            id_token_claims: {
              oid: 'a-valid-oid'
            }
          }
        }
      )

      allow(TeacherVacancyAuthorisation::Permissions).to receive(:new)
        .and_return(AuthHelpers::MockPermissions.new(mock_response))

      visit root_path
      click_on(I18n.t('nav.sign_in'))
      choose(HiringStaff::IdentificationsController::AZURE_SIGN_IN_OPTIONS.first.to_radio.last)
      click_on(I18n.t('sign_in.link'))

      expect(page).to have_content('Select your organisation')
      choose other_school.name
      click_on 'Continue'
    end

    scenario 'offer the ability to select which school to sign-in with' do
      expect(page).to have_content("Jobs at #{other_school.name}")
      within('#proposition-links') { expect(page).to have_content(I18n.t('nav.sign_out')) }
      within('#proposition-links') { expect(page).to have_content(I18n.t('nav.school_page_link')) }
      within('#proposition-links') { expect(page).to have_selector('a.active', text: 'My jobs') }
    end

    scenario 'adds entries in the audit log' do
      activities = PublicActivity::Activity.all

      expect(activities[0].key).to eq('azure.authentication.success')
      expect(activities[1].key).to eq('azure.authorisation.select_school')
      expect(activities[2].key).to eq('azure.authorisation.success')
      expect(activities[2].trackable.urn).to eq(other_school.urn)
    end

    context 'allows the user to switch between organisation' do
      before(:each) do
        click_on 'Change organisation'

        expect(page).to have_content('Select your organisation')
        choose school.name
        click_on 'Continue'
      end

      scenario 'allows the user to switch between orgnisations and logs audit events' do
        expect(page).to have_content("Jobs at #{school.name}")
      end

      scenario 'adds entries to the audit log' do
        activities = PublicActivity::Activity.all

        expect(activities[3].key).to eq('azure.authentication.success')
        expect(activities[4].key).to eq('azure.authorisation.select_school')
        expect(activities[5].key).to eq('azure.authorisation.success')
        expect(activities[5].trackable.urn).to eq(school.urn)
      end
    end
  end

  context 'with valid credentials that do not match a school' do
    before(:each) do
      OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(
        provider: 'default',
        info: {
          name: 'an-email@example.com',
        },
        extra: {
          raw_info: {
            id_token_claims: {
              oid: 'an-unknown-oid'
            }
          }
        }
      )

      mock_response = double(code: '200', body: { user: { permissions: [] } }.to_json)
      expect(TeacherVacancyAuthorisation::Permissions).to receive(:new)
        .and_return(AuthHelpers::MockPermissions.new(mock_response))
      visit root_path

      click_on(I18n.t('nav.sign_in'))
      choose(HiringStaff::IdentificationsController::AZURE_SIGN_IN_OPTIONS.first.to_radio.last)
      click_on(I18n.t('sign_in.link'))
    end

    scenario 'it does not sign-in the user' do
      expect(page).to have_content(I18n.t('static_pages.not_authorised.title'))
      within('#proposition-links') { expect(page).not_to have_content(I18n.t('nav.school_page_link')) }
    end

    scenario 'adds entries in the audit log' do
      authentication = PublicActivity::Activity.first
      expect(authentication.key).to eq('azure.authentication.success')

      authorisation = PublicActivity::Activity.last
      expect(authorisation.key).to eq('azure.authorisation.failure')
    end
  end

  context 'with invalid credentials are unable to access the service' do
    before(:each) do
      OmniAuth.config.mock_auth[:default] = :invalid_credentials

      visit root_path
      click_on(I18n.t('nav.sign_in'))
      choose(HiringStaff::IdentificationsController::AZURE_SIGN_IN_OPTIONS.first.to_radio.last)
      click_on(I18n.t('sign_in.link'))
    end

    scenario 'renders an error' do
      expect(page).to have_content(I18n.t('errors.sign_in.failure'))
    end

    scenario 'adds an entry in the audit log' do
      activity = PublicActivity::Activity.last
      expect(activity.key).to eq('azure.authentication.failure')
    end
  end
end
