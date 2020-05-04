require 'rails_helper'

RSpec.describe SubscriptionReferenceGenerator do
  describe '.new' do
    it 'should be initialised with a hash of search criteria' do
      service = described_class.new(search_criteria: { 'subject' => 'Maths', 'radius' => 20 })
      expect(service).to be_an_instance_of(described_class)
    end
  end

  describe '#generate' do
    context 'with no common fields in search criteria' do
      let(:params) do
        { search_criteria: { 'radius' => 20, 'working_pattern' => 'full_time' } }
      end

      it 'returns nil' do
        service = described_class.new(params)

        expect(service.generate).to eq(nil)
      end
    end

    context 'with keyword in search criteria' do
      let(:params) { { search_criteria: { 'keyword' => 'maths and science', 'radius' => 20 } } }

      it 'returns a reference containing the subject' do
        service = described_class.new(params)

        expect(service.generate).to include('Maths and science jobs')
      end
    end

    context 'with location and radius in search criteria' do
      let(:params) { { search_criteria: { 'location' => 'SW1A 1AA', 'radius' => 40 } } }

      it 'returns a reference containing the location and radius' do
        service = described_class.new(params)

        expect(service.generate).to include('within 40 miles of SW1A 1AA')
      end
    end
  end
end
