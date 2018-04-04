require 'rails_helper'
RSpec.feature 'Hiring staff can log in' do
  before do
    OmniAuth.config.test_mode = true
  end

  after(:each) do
    OmniAuth.config.mock_auth[:default] = nil
  end

  let!(:school) { create(:school, urn: '110627') }

  scenario 'with valid credentials', elasticsearch: true do
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(
      provider: 'default',
      uid: 'ff01631e-eaa6-4bdd-bb78-b563012c42b5'
    )

    visit root_path

    click_on('School sign in')

    expect(page).to have_content("Vacancies at #{school.name}")
  end

  scenario 'with invalid credentials' do
    OmniAuth.config.mock_auth[:default] = :invalid_credentials

    visit root_path

    click_on('School sign in')

    expect(page).to have_content(I18n.t('errors.sign_in.failure'))
  end
end
