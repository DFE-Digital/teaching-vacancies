require 'rails_helper'
RSpec.feature 'Hiring staff can sign out' do
  let(:school) { create(:school) }

  scenario 'as an authenticated user' do
    stub_hiring_staff_auth(urn: school.urn)

    visit root_path

    click_on(I18n.t('nav.sign_out'))
    within('.govuk-header__navigation') { expect(page).to have_content(I18n.t('nav.sign_in')) }
    expect(page).to have_content(I18n.t('messages.access.signed_out'))
  end
end
