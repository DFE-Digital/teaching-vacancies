require 'rails_helper'

RSpec.describe SubscriptionFinder do
  describe '.new' do
    it 'should be initialised with a hash of params' do
      service = described_class.new(email: 'foo', search_criteria: 'bar', frequency: 'daily')
      expect(service).to be_an_instance_of(described_class)
    end
  end

  describe '#exists?' do
    let(:params) { { email: 'foo@email.com', search_criteria: 'bar', frequency: 'daily' } }
    context 'when there are no existing subscriptions' do
      it 'returns false' do
        service = described_class.new(params)
        expect(service.exists?).to eq(false)
      end
    end

    context 'when an existing subscription exists with email, search_criteria and frequency' do
      before(:each) do
        create(
          :daily_subscription,
          email: 'foo@email.com',
          search_criteria: 'bar',
          frequency: 'daily'
        )
      end

      it 'returns true' do
        service = described_class.new(params)
        expect(service.exists?).to eq(true)
      end
    end
  end
end
