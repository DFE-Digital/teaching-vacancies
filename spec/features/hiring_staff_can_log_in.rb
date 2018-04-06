require 'rails_helper'
RSpec.feature 'Hiring staff can log in' do
  before do
    OmniAuth.config.test_mode = true
  end

  after(:each) do
    OmniAuth.config.mock_auth[:default] = nil
  end

  let!(:school) { create(:school, urn: '110627') }
  before(:each) do
    stub_const('Permission::USER_TO_SCHOOL_MAPPING', 'a-valid-oid' => school.urn)
  end

  scenario 'with valid credentials that do match a school', elasticsearch: true do
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(
      provider: 'default',
      extra: {
        raw_info: {
          id_token_claims: {
            oid: 'a-valid-oid'
          }
        }
      }
    )

    visit root_path

    click_on('School sign in')

    expect(page).to have_content("Vacancies at #{school.name}")
  end

  scenario 'with valid credentials that do not match a school', elasticsearch: true do
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(
      provider: 'default',
      extra: {
        raw_info: {
          id_token_claims: {
            oid: 'an-unknown-oid'
          }
        }
      }
    )

    visit root_path

    click_on('School sign in')

    expect(page).to have_content(I18n.t('errors.sign_in.unauthorised'))
  end

  scenario 'with invalid credentials' do
    OmniAuth.config.mock_auth[:default] = :invalid_credentials

    visit root_path

    click_on('School sign in')

    expect(page).to have_content(I18n.t('errors.sign_in.failure'))
  end
end
