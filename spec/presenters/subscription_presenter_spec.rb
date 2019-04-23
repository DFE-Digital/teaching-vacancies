require 'rails_helper'
RSpec.describe SubscriptionPresenter do
  let(:presenter) { described_class.new(subscription) }
  let(:subscription) { Subscription.new(search_criteria: search_criteria.to_json, reference: reference) }
  let(:search_criteria) { { keyword: 'english' } }
  let(:reference) { 'Maths Teacher' }

  describe '#formatted_search_criteria' do
    context 'with the location filter' do
      let(:search_criteria) { { location: 'EC2 9AN', radius: '10' } }

      it 'formats and returns the search criteria' do
        expect(presenter.filtered_search_criteria['location']).to eq('Within 10 miles of EC2 9AN')
      end
    end

    context 'without location information' do
      let(:search_criteria) { { radius: '10' } }

      it 'does not return location or radius information' do
        expect(presenter.filtered_search_criteria.key?('location')).to eq(false)
        expect(presenter.filtered_search_criteria.key?('radius')).to eq(false)
      end
    end

    context 'with the salary filters' do
      let(:search_criteria) { { minimum_salary: '10', maximum_salary: '2000' } }

      it 'formats and returns the salary criteria' do
        expect(presenter.filtered_search_criteria['minimum_salary']).to eq('£10')
        expect(presenter.filtered_search_criteria['maximum_salary']).to eq('£2,000')
      end
    end

    context 'with the working_pattern filter' do
      let(:search_criteria) { { working_pattern: 'part_time' } }

      it 'formats and returns the working pattern' do
        expect(presenter.filtered_search_criteria['working_pattern']).to eq('Part time')
      end
    end

    context 'with the phases filter' do
      let(:search_criteria) { { phases: ['secondary', 'sixteen_plus'] } }

      it 'formats and returns the phases' do
        expect(presenter.filtered_search_criteria['phases']).to eq('Secondary, Sixteen plus')
      end
    end

    context 'with the NQT filter' do
      let(:search_criteria) { { newly_qualified_teacher: 'true' } }

      it 'formats and returns the working pattern' do
        expect(presenter.filtered_search_criteria['']).to eq('Suitable for NQTs')
      end
    end

    context 'with unsorted filters' do
      let(:search_criteria) do
        {
          phases: ['secondary', 'sixteen_plus'],
          maximum_salary: '2000',
          radius: '10',
          job_title: 'leader',
          newly_qualified_teacher: 'true',
          location: 'EC2 9AN',
          minimum_salary: '10',
          working_pattern: 'part_time',
          subject: 'maths'
        }
      end

      it 'returns the filters in sort order' do
        expect(presenter.filtered_search_criteria).to eq(
          'location' => 'Within 10 miles of EC2 9AN',
          'subject' => 'maths',
          'job_title' => 'leader',
          'minimum_salary' => '£10',
          'maximum_salary' => '£2,000',
          'working_pattern' => 'Part time',
          'phases' => 'Secondary, Sixteen plus',
          '' => 'Suitable for NQTs'
        )
      end
    end
  end

  describe '#extended_search_criteria' do
    let(:extended_search_criteria) { presenter.send(:extended_search_criteria) }

    it 'adds all possible search criteria to subscription criteria' do
      expect(extended_search_criteria.count).to eq(VacancyAlertFilters::AVAILABLE_FILTERS.count)
      expect(extended_search_criteria.keys).to match_array(VacancyAlertFilters::AVAILABLE_FILTERS)
      expect(extended_search_criteria[:keyword]).to eq(search_criteria[:keyword])
    end
  end

  describe '#to_row' do
    let(:to_row) { presenter.to_row }

    it 'returns the right number of keys' do
      expect(to_row.count).to eq(VacancyAlertFilters::AVAILABLE_FILTERS.count + 1)
    end

    it 'returns the reference' do
      expect(to_row[:reference]).to eq(reference)
      expect(to_row[:keyword]).to eq(search_criteria[:keyword])
    end

    it 'returns the search criteria' do
      expect(to_row[:working_pattern]).to eq(nil)
      expect(to_row.keys.last).to eq(:reference)
    end
  end
end
