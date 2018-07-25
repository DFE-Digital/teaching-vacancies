require 'rails_helper'

RSpec.feature 'Job seekers can apply for a vacancy' do
  scenario 'the application link is without protocol', browerstack: true do
    vacancy = create(:vacancy, :published, application_link: 'www.google.com')

    visit job_path(vacancy)

    expect(page).to have_link(I18n.t('jobs.apply', href: 'http://www.google.com'))
  end
end
