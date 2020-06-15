require 'rails_helper'
RSpec.feature 'Hiring staff can sign out' do
  let(:school) { create(:school) }

  scenario 'as an authenticated user' do
    stub_hiring_staff_auth(urn: school.urn)

    visit root_path

    click_on(I18n.t('nav.sign_out'))

    # A request to logout is sent to DfE Sign-in system. On success DSI comes back at auth_dfe_signout_path
    expect(page.current_url).to include "#{ENV['DFE_SIGN_IN_ISSUER']}/session/end"
    expect(page.current_url).to include CGI.escape(auth_dfe_signout_url)
    visit auth_dfe_signout_path

    within('.govuk-header__navigation') { expect(page).to have_content(I18n.t('nav.sign_in')) }
    expect(page).to have_content(I18n.t('messages.access.signed_out'))
  end
end
