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

    context 'with the location category filter' do
      let(:search_criteria) { { location_category: 'Barnet', location: 'Barnet' } }

      it 'formats and returns the search criteria' do
        expect(presenter.filtered_search_criteria['location']).to eq('In Barnet')
      end
    end

    context 'without location information' do
      let(:search_criteria) { { radius: '10' } }

      it 'does not return location or radius information' do
        expect(presenter.filtered_search_criteria.key?('location')).to eq(false)
        expect(presenter.filtered_search_criteria.key?('radius')).to eq(false)
      end
    end

    context 'with the working_patterns filter' do
      let(:search_criteria) { { working_patterns: ['part_time'] } }

      it 'formats and returns the working pattern' do
        expect(presenter.filtered_search_criteria['working_patterns']).to eq('Part-time')
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
          radius: '10',
          job_title: 'leader',
          newly_qualified_teacher: 'true',
          location: 'EC2 9AN',
          working_patterns: ['part_time'],
          subject: 'maths'
        }
      end

      it 'returns the filters in sort order' do
        expect(presenter.filtered_search_criteria).to eq(
          'location' => 'Within 10 miles of EC2 9AN',
          'subject' => 'maths',
          'job_title' => 'leader',
          'working_patterns' => 'Part-time',
          'phases' => 'Secondary, Sixteen plus',
          '' => 'Suitable for NQTs'
        )
      end
    end

    context 'with unknown filters' do
      let(:search_criteria) do
        {
          radius: '10',
          something: 'test',
          job_title: 'leader',
          newly_qualified_teacher: 'true',
          something_else: 'testing',
          location: 'EC2 9AN',
          subject: 'maths'
        }
      end

      it 'returns the unknown filters last' do
        expect(presenter.filtered_search_criteria).to eq(
          'location' => 'Within 10 miles of EC2 9AN',
          'subject' => 'maths',
          'job_title' => 'leader',
          '' => 'Suitable for NQTs',
          'something' => 'test',
          'something_else' => 'testing'
        )
      end
    end
  end

  describe '#full_search_criteria' do
    let(:full_search_criteria) { presenter.send(:full_search_criteria) }

    it 'adds all possible search criteria to subscription criteria' do
      expect(full_search_criteria.count).to eq(described_class::SEARCH_CRITERIA_SORT_ORDER.count)
      expect(full_search_criteria.keys).to match_array(described_class::SEARCH_CRITERIA_SORT_ORDER)
      expect(full_search_criteria[:keyword]).to eq(search_criteria[:keyword])
    end
  end

  describe '#to_row' do
    let(:to_row) { presenter.to_row }

    it 'returns the right number of keys' do
      expect(to_row.count).to eq(described_class::SEARCH_CRITERIA_SORT_ORDER.count + 1)
    end

    it 'returns the reference' do
      expect(to_row[:reference]).to eq(reference)
      expect(to_row[:keyword]).to eq(search_criteria[:keyword])
    end

    it 'returns the search criteria' do
      expect(to_row[:working_pattern]).to eq(nil)
      expect(to_row.keys.last).to eq(:reference)
    end

    context 'when array values in search criteria' do
      let(:search_criteria) { { phases: ['primary', 'secondary', 'sixteen_plus'] } }

      it 'makes them human readable' do
        expect(to_row[:phases]).to eq('primary, secondary, sixteen_plus')
      end
    end
  end
end
