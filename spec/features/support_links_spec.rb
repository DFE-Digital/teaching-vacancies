require 'rails_helper'

RSpec.feature 'A visitor to the website can access the support links' do
  scenario 'the cookie policy' do
    visit root_path
    click_on 'Cookies'

    expect(page).to have_content('Cookies')
    expect(page).to have_content("'Teaching Vacancies' puts small files (known as 'cookies') onto your computer " \
                                 'to collect information about how you use the site.')
  end

  scenario 'the privacy policy' do
    visit root_path
    click_on 'Privacy policy'

    expect(page).to have_content('Privacy Notice: Teaching Vacancies')
    expect(page).to have_content(I18n.t('static_pages.privacy_policy.who_we_are.about'))
  end

  scenario 'the terms and conditions' do
    visit root_path
    click_on 'Terms and Conditions'

    expect(page).to have_content(I18n.t('static_pages.terms_and_conditions.title'))

    expect(page).to have_content(I18n.t('static_pages.terms_and_conditions.all_users.using_the_website.text').first)
  end
end
