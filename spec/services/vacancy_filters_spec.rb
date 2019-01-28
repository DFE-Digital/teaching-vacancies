require 'rails_helper'
RSpec.describe VacancyFilters do
  describe '#initialize' do
    it 'sets the keyword filter if provided' do
      vacancy_filters = VacancyFilters.new(keyword: 'geography')
      expect(vacancy_filters.keyword).to eq('geography')
    end

    it 'sets the location filter if provided' do
      vacancy_filters = VacancyFilters.new(location: 'durham')
      expect(vacancy_filters.location).to eq('durham')
    end

    it 'sets the minimum salary filter if provided' do
      vacancy_filters = VacancyFilters.new(minimum_salary: 10000)
      expect(vacancy_filters.minimum_salary).to eq(10000)
    end

    it 'sets the maximum salary filter if provided' do
      vacancy_filters = VacancyFilters.new(maximum_salary: 20000)
      expect(vacancy_filters.maximum_salary).to eq(20000)
    end

    it 'sets the working pattern filter if provided and valid' do
      vacancy_filters = VacancyFilters.new(working_pattern: 'full_time')
      expect(vacancy_filters.working_pattern).to eq('full_time')
    end

    it 'sets the newly qualified teacher filter if provided' do
      vacancy_filters = VacancyFilters.new(newly_qualified_teacher: true)
      expect(vacancy_filters.newly_qualified_teacher).to eq(true)
    end

    it 'does not set the working pattern filter if invalid' do
      vacancy_filters = VacancyFilters.new(working_pattern: 'home_time')
      expect(vacancy_filters.working_pattern).to be_nil
    end

    it 'sets the education phase filter if provided and valid' do
      vacancy_filters = VacancyFilters.new(phase: 'primary')
      expect(vacancy_filters.phase).to eq('primary')
    end

    it 'does not set the education phase filter if invalid' do
      vacancy_filters = VacancyFilters.new(phase: 'kindergarten')
      expect(vacancy_filters.phase).to be_nil
    end

    it 'does not set filters for any other given params' do
      vacancy_filters = VacancyFilters.new(column: 'expires_on')
      expect { vacancy_filters.column }.to raise_error(NoMethodError)
    end
  end

  describe '#to_hash' do
    it 'returns a hash of the reader attributes' do
      filters = described_class.new(
        location: 'location',
        keyword: 'keyword',
        radius: 20,
        minimum_salary: 'minimum_salary',
        maximum_salary: 'maximum_salary',
        working_pattern: 'working_pattern',
        newly_qualified_teacher: false,
        phase: 'phase',
      )

      result = filters.to_hash

      expect(result).to eql(
        location: 'location',
        keyword: 'keyword',
        radius: '20',
        minimum_salary: 'minimum_salary',
        maximum_salary: 'maximum_salary',
        newly_qualified_teacher: false,
        working_pattern: nil,
        phase: nil
      )
    end
  end

  describe '#any?' do
    it 'returns true if any filters other than radius are set' do
      filters = described_class.new(
        radius: 20
      )

      expect(filters.any?).to be false
    end

    it 'returns true if any filters are set' do
      filters = described_class.new(
        minimum_salary: 'minimum_salary',
        maximum_salary: 'maximum_salary',
      )

      expect(filters.any?).to be true
    end
  end
end
