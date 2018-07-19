require 'rails_helper'
RSpec.feature 'Hiring staff can sign in with Azure' do
  before do
    OmniAuth.config.test_mode = true
  end

  after(:each) do
    OmniAuth.config.mock_auth[:default] = nil
  end

  let!(:school) { create(:school, urn: '110627') }

  scenario 'with valid credentials that do match a school', elasticsearch: true do
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
    mock_response = double(body: {
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

    expect(page).to have_content("Jobs at #{school.name}")
    within('#proposition-links') { expect(page).to have_content(I18n.t('nav.sign_out')) }
    within('#proposition-links') { expect(page).to have_content(I18n.t('nav.school_page_link')) }
    within('#proposition-links') { expect(page).to have_selector('a.active', text: 'My jobs') }
  end

  scenario 'with valid credentials that do not match a school', elasticsearch: true do
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

    mock_response = double(body: { user: { permissions: [] } }.to_json)
    expect(TeacherVacancyAuthorisation::Permissions).to receive(:new)
      .and_return(AuthHelpers::MockPermissions.new(mock_response))

    visit root_path

    click_on(I18n.t('nav.sign_in'))

    expect(page).to have_content(I18n.t('static_pages.not_authorised.title'))
    within('#proposition-links') { expect(page).not_to have_content(I18n.t('nav.school_page_link')) }
  end

  scenario 'with invalid credentials' do
    OmniAuth.config.mock_auth[:default] = :invalid_credentials

    visit root_path

    click_on(I18n.t('nav.sign_in'))

    expect(page).to have_content(I18n.t('errors.sign_in.failure'))
  end
end
