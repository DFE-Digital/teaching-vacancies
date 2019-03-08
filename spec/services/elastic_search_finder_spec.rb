require 'rails_helper'
RSpec.describe ElasticSearchFinder do
  describe '#call' do
    it 'searches elasticsearch and asks for the default pagination amount' do
      expect(Vacancy).to receive_message_chain(:__elasticsearch__, :search)
        .with(a_hash_including(size: Vacancy.default_per_page))
      described_class.new.call({}, {})
    end

    it 'searches elasticsearch with the provided query and sort params' do
      expect(Vacancy).to receive_message_chain(:__elasticsearch__, :search)
        .with(a_hash_including(query: {}, sort: {}))
      described_class.new.call({}, {})
    end
  end
end
