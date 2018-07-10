require 'rails_helper'
require 'permission'
RSpec.feature 'Hiring staff can sign in with DfE Sign In' do
  before do
    OmniAuth.config.test_mode = true
    ENV['SIGN_IN_WITH_DFE'] = 'true'
  end

  after(:each) do
    OmniAuth.config.mock_auth[:default] = nil
    ENV['SIGN_IN_WITH_DFE'] = 'false'
  end

  let!(:school) { create(:school, urn: '110627') }
  before(:each) do
    stub_const('Permission::HIRING_STAFF_USER_TO_SCHOOL_MAPPING', 'a-valid-oid' => school.urn)
  end

  scenario 'with valid credentials that do match a school', elasticsearch: true do
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      provider: 'dfe',
      uid: 'a-valid-oid'
    )

    visit root_path

    click_on(I18n.t('nav.sign_in'))

    expect(page).to have_content("Jobs at #{school.name}")
    within('#proposition-links') { expect(page).to have_content(I18n.t('nav.sign_out')) }
    within('#proposition-links') { expect(page).to have_content(I18n.t('nav.school_page_link')) }
  end

  scenario 'with valid credentials that do not match a school', elasticsearch: true do
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      provider: 'dfe',
      uid: 'an-unknown-oid'
    )

    visit root_path

    click_on(I18n.t('nav.sign_in'))

    expect(page).to have_content(I18n.t('errors.sign_in.unauthorised'))
    within('#proposition-links') { expect(page).not_to have_content(I18n.t('nav.school_page_link')) }
  end
end
