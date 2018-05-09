require 'rails_helper'
require 'permission'

RSpec.feature 'School viewing public listings' do
  before do
    OmniAuth.config.test_mode = true
  end

  after(:each) do
    OmniAuth.config.mock_auth[:default] = nil
  end

  let!(:school) { create(:school, urn: '110627') }
  before(:each) do
    stub_const('Permission::HIRING_STAFF_USER_TO_SCHOOL_MAPPING', 'a-valid-oid' => school.urn)
  end

  scenario 'A signed in school should see a link back to their own dashboard when viewing public listings' do
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

    click_on(I18n.t('nav.sign_in'))
    expect(page).to have_content("Jobs at #{school.name}")
    within('#proposition-links') { expect(page).to have_content(I18n.t('nav.school_page_link')) }

    click_on(I18n.t('app.title'))
    expect(page).to have_content(I18n.t('jobs.heading'))

    click_on(I18n.t('nav.school_page_link'))
    expect(page).to have_content("Jobs at #{school.name}")
  end
end
