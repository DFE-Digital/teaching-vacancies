require 'rails_helper'
RSpec.describe SchoolVacanciesPresenter do
  let(:school) { create(:school) }
  let(:type) { 'published' }
  let(:presenter) { described_class.new(school, type) }

  let!(:draft_vacancies) { create_list(:vacancy, 5, :draft, school: school) }
  let!(:pending_vacancies) { create_list(:vacancy, 2, :future_publish, school: school) }
  let!(:expired_vacancies) do
    expired_vacancies = []
    3.times do
      expired_vacancy = build(:vacancy, :expired, school: school)
      expired_vacancy.save(validate: false)
      expired_vacancies << expired_vacancy
    end
    expired_vacancies
  end
  let!(:live_vacancies) { create_list(:vacancy, 7, :published, school: school) }

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
  end

  context 'when type is pending' do
    let(:type) { 'pending' }

    it 'returns the vacancy type' do
      expect(presenter.vacancy_type).to eq(:pending)
    end

    it 'returns draft vacancies' do
      expect(presenter.vacancies.count).to eq(pending_vacancies.count)
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
  end

  context 'when type is published' do
    let(:type) { 'published' }

    it 'returns the vacancy type' do
      expect(presenter.vacancy_type).to eq(:published)
    end

    it 'returns draft vacancies' do
      expect(presenter.vacancies.count).to eq(live_vacancies.count)
    end
  end

  context 'when type is not recognised' do
    let(:type) { 'something' }

    it 'raises an error ' do
      expect { presenter }.to raise_error(ArgumentError)
    end
  end
end