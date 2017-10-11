require 'rails_helper'

RSpec.describe VacancyPresenter do

  describe '#salary_range' do
    it 'return the formatted minimum to maximum salary' do
      vacancy = VacancyPresenter.new(create(:vacancy, minimum_salary: 30000, maximum_salary: 40000))
      expect(vacancy.salary_range).to eq('£30,000 - £40,000')
    end

    it 'returns the formatted minumum to maximum salary with the specified delimiter' do
      vacancy = VacancyPresenter.new(create(:vacancy, minimum_salary: 30000, maximum_salary: 40000))
      expect(vacancy.salary_range("to")).to eq('£30,000 to £40,000')
    end

    context 'when no maximum salary is set' do
      it 'should just return the minimum salary' do
        vacancy = VacancyPresenter.new(create(:vacancy, minimum_salary: 20000, maximum_salary: nil))
        expect(vacancy.salary_range).to eq('£20,000')
      end
    end
  end

  describe '#expired?' do
    it 'returns true when the vacancy has expired' do

      vacancy = VacancyPresenter.new(build(:vacancy, expires_on: 4.days.ago))
      expect(vacancy).to be_expired
    end

    it 'returns false when the vacancy expires today' do
      vacancy = VacancyPresenter.new(build(:vacancy, expires_on: Time.zone.today))
      expect(vacancy).not_to be_expired
    end

    it 'returns false when the vacancy has yet to expire' do
      vacancy = VacancyPresenter.new(build(:vacancy, expires_on: 6.days.from_now))
      expect(vacancy).not_to be_expired
    end
  end
end
