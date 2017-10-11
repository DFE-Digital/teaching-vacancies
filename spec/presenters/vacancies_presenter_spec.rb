require 'rails_helper'

RSpec.describe VacanciesPresenter do

  describe '#each' do

    it 'is delegated to the decorated collection' do
      vacancies = 3.times.map { create(:vacancy) }

      decorated_vacancies = vacancies.map { |v| VacancyPresenter.new(v) }
      vacancies_presenter = VacanciesPresenter.new(vacancies)
      allow(vacancies_presenter).to receive(:decorated_collection).and_return(decorated_vacancies)

      expect(decorated_vacancies).to receive(:each)

      vacancies_presenter.each {}
    end
  end
end
