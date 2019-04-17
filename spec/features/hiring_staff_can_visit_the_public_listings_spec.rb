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

  context 'when signed in with DfE Sign In' do
    before(:each) do
      stub_accepted_terms_and_condition
      stub_authentication_step(school_urn: '110627')
      stub_authorisation_step
    end

    scenario 'A signed in school should see a link back to their own dashboard when viewing public listings' do
      visit root_path

      click_on(I18n.t('nav.sign_in'))
      click_on(I18n.t('sign_in.link'))

      expect(page).to have_content("Jobs at #{school.name}")
      within('.app-navigation') { expect(page).to have_content(I18n.t('nav.school_page_link')) }

      click_on(I18n.t('app.title'))
      expect(page).to have_content(I18n.t('jobs.heading'))

      click_on(I18n.t('nav.school_page_link'))
      expect(page).to have_content("Jobs at #{school.name}")
    end
  end

  def stub_accepted_terms_and_condition
    create(:user, oid: '161d1f6a-44f1-4a1a-940d-d1088c439da7', accepted_terms_at: 1.day.ago)
  end
end
