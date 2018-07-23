require 'rails_helper'

RSpec.feature 'Hiring staff from a school in an area that has not been invited yet' do
  scenario 'redirects the user to the root path with a call to action' do
    visit root_path
    click_on(I18n.t('nav.sign_in'))
    choose(HiringStaff::IdentificationsController::OTHER_SIGN_IN_OPTION.first.to_radio.last)
    click_on(I18n.t('sign_in.link'))
    expect(page).to have_content(I18n.t('app.title'))
    expect(page).to have_content("Other areas have not been invited yet, \
      please register your interest by emailing us at #{I18n.t('help.email')}")
  end
end
