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
    expect(page).to have_content('This work is being carried out by Department for Education (DfE) Digital, ' \
                                 'which is a part of DfE. DfE engages the private company dxw to help improve ' \
                                 'and provide the service. For the purpose of data protection legislation, ' \
                                 'the DfE is the data controller for the personal data processed as part of ' \
                                 'Teaching Vacancies. Teaching Vacancies is a free and optional service for schools ' \
                                 'to list teaching roles.')
  end

  scenario 'the terms and conditions' do
    visit root_path
    click_on 'Terms and Conditions'

    expect(page).to have_content('Terms and Conditions')

    expect(page).to have_content('Please read these Terms of Use (“General Terms”) carefully before using ' \
                                 'this Teaching Vacancies website (the “Service”).')
  end
end
