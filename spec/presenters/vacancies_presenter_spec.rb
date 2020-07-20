require 'rails_helper'
RSpec.describe VacanciesPresenter do
  describe '#each' do
    it 'is delegated to the decorated collection' do
      create_list(:vacancy, 3)
      vacancies = Vacancy.all.page(1)
      searched = true
      decorated_vacancies = vacancies.map { |v| VacancyPresenter.new(v) }

      vacancies_presenter = VacanciesPresenter.new(
        vacancies,
        searched: searched,
        total_count:
        vacancies.count
      )

      allow(vacancies_presenter).to receive(:decorated_collection).and_return(decorated_vacancies)

      expect(decorated_vacancies).to receive(:each)

      vacancies_presenter.each {}
    end
  end

  describe '#total_count_message' do
    let(:vacancies) { double('vacancies').as_null_object }

    before do
      allow(vacancies).to receive(:count).and_return(total_count)
    end

    context 'with search' do
      let(:searched) { true }

      context 'for a single vacancy' do
        let(:total_count) { 1 }

        it 'returns the correct number' do
          vacancies_presenter = VacanciesPresenter.new(
            vacancies,
            searched: searched,
            total_count: vacancies.count
          )
          expect(vacancies_presenter.search_heading(keyword: 'physics')).to eq(
            I18n.t('jobs.search_result_heading.keyword_html',
              jobs_count: number_with_delimiter(total_count), count: total_count, keyword: 'physics')
          )
        end
      end

      context 'for multiple vacancies' do
        let(:total_count) { 3 }

        it 'returns the correct number' do
          vacancies_presenter = VacanciesPresenter.new(
            vacancies,
            searched: searched,
            total_count: vacancies.count
          )
          expect(vacancies_presenter.search_heading(keyword: 'physics')).to eq(
            I18n.t('jobs.search_result_heading.keyword_html',
              jobs_count: number_with_delimiter(total_count), count: total_count, keyword: 'physics')
          )
        end
      end
    end

    context 'without search' do
      let(:searched) { false }

      context 'for a single vacancy' do
        let(:total_count) { 1 }

        it 'returns the correct number' do
          vacancies_presenter = VacanciesPresenter.new(
            vacancies,
            searched: searched,
            total_count: vacancies.count
          )
          expect(vacancies_presenter.search_heading()).to eq(
            I18n.t('jobs.search_result_heading.without_search_html',
              jobs_count: number_with_delimiter(total_count), count: total_count)
          )
        end
      end

      context 'for multiple vacancies' do
        let(:total_count) { 3 }

        it 'returns the correct number' do
          vacancies_presenter = VacanciesPresenter.new(
            vacancies,
            searched: searched,
            total_count: vacancies.count
          )
          expect(vacancies_presenter.search_heading()).to eq(
            I18n.t('jobs.search_result_heading.without_search_html',
              jobs_count: number_with_delimiter(total_count), count: total_count)
          )
        end
      end
    end
  end

  describe '#previous_api_url' do
    let(:vacancies_presenter) {
      VacanciesPresenter.new(
        vacancies,
        searched: false,
        total_count: vacancies.total_count
      )
    }
    let(:vacancies) { double(:vacancies, map: [], prev_page: prev_page, total_count: 0) }

    context 'when there is a previous page' do
      let(:prev_page) { 4 }

      it 'returns the full url of the next page' do
        expect(vacancies_presenter.previous_api_url).to eq('https://localhost:3000/api/v1/jobs.json?page=4')
      end
    end

    context 'when there is no previous page' do
      let(:prev_page) { nil }

      it 'returns nil' do
        expect(vacancies_presenter.previous_api_url).to be_nil
      end
    end
  end

  describe '#next_api_url' do
    let(:vacancies_presenter) {
      VacanciesPresenter.new(
        vacancies,
        searched: false,
        total_count: vacancies.total_count
      )
    }
    let(:vacancies) { double(:vacancies, map: [], next_page: next_page, total_count: 0) }

    context 'when there is a next page' do
      let(:next_page) { 2 }

      it 'returns the full url of the next page' do
        expect(vacancies_presenter.next_api_url).to eq('https://localhost:3000/api/v1/jobs.json?page=2')
      end
    end

    context 'when there is no next page' do
      let(:next_page) { nil }

      it 'returns nil' do
        expect(vacancies_presenter.next_api_url).to be_nil
      end
    end
  end
end
