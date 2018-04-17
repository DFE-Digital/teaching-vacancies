require 'rails_helper'

RSpec.feature 'Job seekers can apply for a vacancy' do
  scenario 'the application link is without protocol' do
    vacancy = create(:vacancy, :published, application_link: 'www.google.com')

    visit vacancy_path(vacancy.id)

    expect(page).to have_link(I18n.t('vacancies.apply', href: 'http://www.google.com'))
  end
end
