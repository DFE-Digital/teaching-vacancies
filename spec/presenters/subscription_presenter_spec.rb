require 'rails_helper'
RSpec.describe SubscriptionPresenter do
  describe '#formatted_search_criteria' do
    context 'formats and returns the search criteria' do
      it 'with the location filter' do
        subscription = Subscription.new(search_criteria: { location: 'EC2 9AN',
                                                           radius: '10' }.to_json)
        presenter = SubscriptionPresenter.new(subscription)

        expect(presenter.filtered_search_criteria['location']).to eq('Within 10 miles of EC2 9AN')
      end

      it 'without location information unless both location and radius are set' do
        subscription = Subscription.new(search_criteria: { radius: '10' }.to_json)
        presenter = SubscriptionPresenter.new(subscription)

        expect(presenter.filtered_search_criteria.key?('location')).to eq(false)
        expect(presenter.filtered_search_criteria.key?('radius')).to eq(false)
      end

      it 'with the formatted salary filters' do
        subscription = Subscription.new(search_criteria: { minimum_salary: '10',
                                                           maximum_salary: '2000' }.to_json)
        presenter = SubscriptionPresenter.new(subscription)

        expect(presenter.filtered_search_criteria['minimum_salary']).to eq('£10')
        expect(presenter.filtered_search_criteria['maximum_salary']).to eq('£2,000')
      end

      it 'with the formatted working_pattern filter' do
        subscription = Subscription.new(search_criteria: { working_pattern: 'part_time' }.to_json)
        presenter = SubscriptionPresenter.new(subscription)

        expect(presenter.filtered_search_criteria['working_pattern']).to eq('Part time')
      end

      it 'with the formatted NQT filter' do
        subscription = Subscription.new(search_criteria: { newly_qualified_teacher: 'true' }.to_json)
        presenter = SubscriptionPresenter.new(subscription)

        expect(presenter.filtered_search_criteria['']).to eq('Suitable for NQTs')
      end
    end
  end
end
