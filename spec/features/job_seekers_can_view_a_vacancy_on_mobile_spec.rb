require 'rails_helper'

RSpec.feature 'Viewing a single vacancy on mobile' do
  scenario 'Published vacancies are viewable' do
    page.driver.header('User-Agent', USER_AGENTS['MOBILE_CHROME'])
    published_vacancy = VacancyPresenter.new(create(:vacancy, :published))

    visit job_path(published_vacancy)

    verify_vacancy_show_page_details(published_vacancy)
  end
end
