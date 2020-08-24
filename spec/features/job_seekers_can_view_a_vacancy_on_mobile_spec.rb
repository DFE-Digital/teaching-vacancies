require 'rails_helper'

RSpec.feature 'Viewing a single vacancy on mobile' do
  let(:school) { create(:school) }

  before(:each) do
    page.driver.header('User-Agent', USER_AGENTS['MOBILE_CHROME'])
  end

  scenario 'Published vacancies are viewable' do
    published_vacancy = create(:vacancy, :published)
    published_vacancy.organisation_vacancies.create(organisation: school)
    published_vacancy = VacancyPresenter.new(published_vacancy)

    visit job_path(published_vacancy)
    verify_vacancy_show_page_details(published_vacancy)
  end

  context 'meta tags' do
    include ActionView::Helpers::SanitizeHelper
    scenario 'the vacancy\'s meta data are rendered correctly' do
      vacancy = create(:vacancy, :published)
      vacancy.organisation_vacancies.create(organisation: school)
      vacancy = VacancyPresenter.new(vacancy)
      visit job_path(vacancy)

      expect(page.find('meta[name="description"]', visible: false)['content'])
        .to eq(strip_tags(vacancy.job_summary))
    end

    scenario 'the vacancy\'s open graph meta data are rendered correctly' do
      vacancy = create(:vacancy, :published)
      vacancy.organisation_vacancies.create(organisation: school)
      vacancy = VacancyPresenter.new(vacancy)
      visit job_path(vacancy)

      expect(page.find('meta[property="og:description"]', visible: false)['content'])
        .to eq(strip_tags(vacancy.job_summary))
    end
  end
end
