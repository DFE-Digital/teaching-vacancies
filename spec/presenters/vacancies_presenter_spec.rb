require 'rails_helper'
RSpec.describe VacanciesPresenter do
  describe '#each' do
    it 'is delegated to the decorated collection' do
      vacancies = create_list(:vacancy, 3)

      decorated_vacancies = vacancies.map { |v| VacancyPresenter.new(v) }
      vacancies_presenter = VacanciesPresenter.new(vacancies)
      allow(vacancies_presenter).to receive(:decorated_collection).and_return(decorated_vacancies)

      expect(decorated_vacancies).to receive(:each)

      vacancies_presenter.each {}
    end
  end

  describe '#total_count', wip: true do
    it 'returns the correct number for a single vacancy', elasticsearch: true do
      create(:vacancy, job_title: 'School teacher')
      Vacancy.__elasticsearch__.client.indices.flush

      vacancies = Vacancy.search('Teacher').records

      vacancies_presenter = VacanciesPresenter.new(vacancies)
      expect(vacancies_presenter.total_count).to eq(I18n.t('vacancies.vacancy_count', count: 1))
    end

    it 'returns the correct number for multiple vacancies', elasticsearch: true do
      create(:vacancy, job_title: 'School teacher')
      create(:vacancy, job_title: 'Math teacher')
      create(:vacancy, job_title: 'English teacher')
      Vacancy.__elasticsearch__.client.indices.flush

      vacancies = Vacancy.search('Teacher').records

      vacancies_presenter = VacanciesPresenter.new(vacancies)
      expect(vacancies_presenter.total_count).to eq(I18n.t('vacancies.vacancy_count_plural', count: 3))
    end
  end
end
