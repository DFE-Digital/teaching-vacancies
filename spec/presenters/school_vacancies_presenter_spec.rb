require 'rails_helper'
RSpec.describe SchoolVacanciesPresenter do
  let(:school) { create(:school) }
  let(:presenter) { described_class.new(school, 'published') }

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

  describe 'initialize' do
    it 'raises an error if the type is not recognised' do
      expect { SchoolVacanciesPresenter.new(school, 'something') }.to raise_error(ArgumentError)
    end
  end

  it 'returns the vacancy type' do
    expect(presenter.vacancy_type).to eq(:published)
  end

  it 'returns the school' do
    expect(presenter.school).to eq(school)
  end

  it 'returns draft vacancies' do
    expect(presenter.draft).to match_array(draft_vacancies)
  end

  it 'returns pending vacancies' do
    expect(presenter.pending).to match_array(pending_vacancies)
  end

  it 'returns expired vacancies' do
    expect(presenter.expired).to match_array(expired_vacancies)
  end

  it 'returns published vacancies' do
    expect(presenter.published).to match_array(live_vacancies)
  end
end