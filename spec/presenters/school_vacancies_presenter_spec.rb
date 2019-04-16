require 'rails_helper'
RSpec.describe SchoolVacanciesPresenter do
  let(:school) { create(:school) }
  let(:sort) { VacancySort.new }
  let(:type) { 'published' }
  let(:presenter) { described_class.new(school, sort, type) }

  let!(:draft_vacancies) { create_list(:vacancy, 5, :draft, school: school) }
  let!(:pending_vacancies) { create_list(:vacancy, 4, :future_publish, school: school) }
  let!(:expired_vacancies) do
    expired_vacancies = []
    3.times do
      expired_vacancy = build(:vacancy, :expired, school: school)
      expired_vacancy.save(validate: false)
      expired_vacancies << expired_vacancy
    end
    expired_vacancies
  end
  let!(:published_vacancies) { create_list(:vacancy, 7, :published, school: school) }

  it 'returns the school' do
    expect(presenter.school).to eq(school)
  end

  context 'when type is draft' do
    let(:type) { 'draft' }

    it 'returns the vacancy type' do
      expect(presenter.vacancy_type).to eq(:draft)
    end

    it 'returns draft vacancies' do
      expect(presenter.vacancies.count).to eq(draft_vacancies.count)
    end

    it 'returns sorted draft vacancies' do
      sort.update(column: 'job_title', order: 'desc')
      vacancy_ids = draft_vacancies.sort_by { |vacancy| vacancy['job_title'] }.reverse.pluck(:id)
      expect(presenter.vacancies.pluck(:id)).to eq(vacancy_ids)
    end
  end

  context 'when type is pending' do
    let(:type) { 'pending' }

    it 'returns the vacancy type' do
      expect(presenter.vacancy_type).to eq(:pending)
    end

    it 'returns pending vacancies' do
      expect(presenter.vacancies.count).to eq(pending_vacancies.count)
    end

    it 'returns sorted pending vacancies' do
      sort.update(column: 'job_title', order: 'desc')
      vacancy_ids = pending_vacancies.sort_by { |vacancy| vacancy['job_title'] }.reverse.pluck(:id)
      expect(presenter.vacancies.pluck(:id)).to eq(vacancy_ids)
    end
  end

  context 'when type is expired' do
    let(:type) { 'expired' }

    it 'returns the vacancy type' do
      expect(presenter.vacancy_type).to eq(:expired)
    end

    it 'returns expired vacancies' do
      expect(presenter.vacancies.count).to eq(expired_vacancies.count)
    end

    it 'returns sorted expired vacancies' do
      sort.update(column: 'job_title', order: 'desc')
      vacancy_ids = expired_vacancies.sort_by { |vacancy| vacancy['job_title'] }.reverse.pluck(:id)
      expect(presenter.vacancies.pluck(:id)).to eq(vacancy_ids)
    end
  end

  context 'when type is published' do
    let(:type) { 'published' }

    it 'returns the vacancy type' do
      expect(presenter.vacancy_type).to eq(:published)
    end

    it 'returns published vacancies' do
      expect(presenter.vacancies.count).to eq(published_vacancies.count)
    end

    it 'returns sorted published vacancies' do
      sort.update(column: 'job_title', order: 'desc')
      vacancy_ids = published_vacancies.sort_by { |vacancy| vacancy['job_title'] }.reverse.pluck(:id)
      expect(presenter.vacancies.pluck(:id)).to match_array(vacancy_ids)
    end
  end

  context 'when type is not recognised' do
    let(:type) { 'something' }

    it 'raises an error ' do
      expect { presenter }.to raise_error(ArgumentError)
    end
  end
end