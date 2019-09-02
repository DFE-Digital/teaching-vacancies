require 'rails_helper'

RSpec.describe VacanciesHelper, type: :helper do
  describe '::SALARY_OPTIONS' do
    it 'returns a hash of salary options' do
      expect(VacanciesHelper::SALARY_OPTIONS).to eq('£20,000' => 20000,
                                                    '£30,000' => 30000,
                                                    '£40,000' => 40000,
                                                    '£50,000' => 50000,
                                                    '£60,000' => 60000,
                                                    '£70,000' => 70000)
    end
  end

  describe '#working_pattern_options' do
    it 'returns an array of vacancy working patterns' do
      expect(helper.working_pattern_options).to eq(
        [
          ['Full-time', 'full_time'],
          ['Part-time', 'part_time'],
          ['Job share', 'job_share'],
          ['Compressed hours', 'compressed_hours'],
          ['Staggered hours', 'staggered_hours']
        ]
      )
    end
  end

  describe '#school_phase_options' do
    it 'returns an array of school phase patterns' do
      expect(helper.school_phase_options).to eq(
        [
          ['Not applicable', 'not_applicable'],
          ['Nursery', 'nursery'],
          ['Primary', 'primary'],
          ['Middle deemed primary', 'middle_deemed_primary'],
          ['Secondary', 'secondary'],
          ['Middle deemed secondary', 'middle_deemed_secondary'],
          ['Sixteen plus', 'sixteen_plus'],
          ['All through', 'all_through']
        ]
      )
    end
  end

  describe 'selected_sorting_method' do
    it 'Returns :closes_soon' do
      sort = VacancySort.new.update(column: 'expires_on', order: 'asc')
      expect(helper.selected_sorting_method(sort: sort)).to eq(:closes_soon)
    end

    it 'Returns :closes_later' do
      sort = VacancySort.new.update(column: 'expires_on', order: 'desc')
      expect(helper.selected_sorting_method(sort: sort)).to eq(:closes_later)
    end

    it 'Returns :latest_posted' do
      sort = VacancySort.new.update(column: 'publish_on', order: 'desc')
      expect(helper.selected_sorting_method(sort: sort)).to eq(:latest_posted)
    end

    it 'Returns :oldest_posted' do
      sort = VacancySort.new.update(column: 'publish_on', order: 'asc')
      expect(helper.selected_sorting_method(sort: sort)).to eq(:oldest_posted)
    end
  end

  describe '#vacancy_params_whitelist' do
    it 'should include all available filtering params' do
      filters = %i[sort_column sort_order page]
      filters.push(*VacancyFilters::AVAILABLE_FILTERS)

      expect(helper.vacancy_params_whitelist).to match_array(filters)
    end
  end
end
