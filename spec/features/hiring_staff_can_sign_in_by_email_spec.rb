require 'rails_helper'

RSpec.feature 'Hiring staff signing in with fallback email authentication' do
  let!(:school) { create(:school) }
  let!(:user_dsi_data) { { 'school_urns'=>[school.urn], 'school_group_uids'=>[3409, 1623] } }
  let!(:user) { create(:user, dsi_data: user_dsi_data, accepted_terms_at: 1.day.ago) }
  let(:login_key) do
    user.emergency_login_keys.create(not_valid_after: Time.zone.now + HiringStaff::IdentificationsController::EMERGENCY_LOGIN_KEY_DURATION)
  end

  before do
    allow(AuthenticationFallback).to receive(:enabled?) { true }
  end

  scenario 'can reach email request page by nav-bar link' do
    visit root_path

    within('.govuk-header__navigation.mobile-header-top-border') { click_on(I18n.t('nav.sign_in')) }
    expect(page).to have_content(I18n.t('hiring_staff.identifications.temp_login.heading'))
    expect(page).to have_content(I18n.t('hiring_staff.identifications.temp_login.please_use_email'))
  end

  scenario 'can reach email request page by sign in button' do
    visit root_path

    within('.signin') { click_on(I18n.t('sign_in.link')) }
    expect(page).to have_content(I18n.t('hiring_staff.identifications.temp_login.heading'))
    expect(page).to have_content(I18n.t('hiring_staff.identifications.temp_login.please_use_email'))
  end

  scenario 'can sign in' do
    freeze_time do
      visit root_path

      click_sign_in

      fill_in 'user[email]', with: user.email

      click_on 'commit'

      expect(page).to have_content(I18n.t('hiring_staff.identifications.temp_login.check_your_email.sent'))

      allow(user).to receive_message_chain(:emergency_login_keys, :create)
        .with(not_valid_after: Time.zone.now + HiringStaff::IdentificationsController::EMERGENCY_LOGIN_KEY_DURATION)
        .and_return(login_key)

      # Expect an email

      message_delivery = instance_double(ActionMailer::MessageDelivery)

      allow(AuthenticationFallbackMailer).to receive(:sign_in_fallback)
        .with(login_key: login_key, email: user.email)
        .and_return(message_delivery)
      expect(message_delivery).to receive(:deliver_later)

      # Expect that the link in the email goes to the landing page

      visit choose_organisation_path(login_key: login_key.id)

      expect(page).to have_content('Choose your organisation')

      click_on school.name

      expect(page).to have_content("Jobs at #{school.name}")
      expect(login_key).to be destroyed

      click_on(I18n.t('nav.sign_out'))

      within('.govuk-header__navigation') { expect(page).to have_content(I18n.t('nav.sign_in')) }
      expect(page).to have_content(I18n.t('messages.access.signed_out'))
    end
  end

  private

  def click_sign_in
    within('.signin') { click_on(I18n.t('sign_in.link')) }
  end
end
