require 'rails_helper'

RSpec.describe VacanciesFinder do
  let(:sort) { VacancySort.new({}) }
  let(:page_number) { 1 }
  let(:subject) { described_class.new(filters, sort, page_number) }

  context 'when parameters are given' do
    let(:filters) { VacancyFilters.new(keyword: 'English') }

    it 'calls ElasticSearch' do
      expect(Vacancy).to receive(:__elasticsearch__).and_call_original

      subject
    end

    it 'invokes pagination correctly to ensure sort order persists' do
      create(:vacancy)

      # This assertion ensures the ordering of search and pagination stays correct
      # in future as the gem allows you to call `page` on 2 similar objects.
      #
      # Correct:
      # - Vacancy.search.page.records
      # - Vacancy.search.page => Elasticsearch::Model::Response::Records
      # Incorrect:
      # - Vacancy.search.records.page
      # - Vacancy.search.records => Elasticsearch::Model::Response::Response

      elasticsearch_response = instance_double(Elasticsearch::Model::Response::Response)
      records = instance_double(Elasticsearch::Model::Response::Records)
      expect(Vacancy).to receive(:public_search).ordered.and_return(elasticsearch_response)
      expect(elasticsearch_response).to receive(:page).ordered.and_return(elasticsearch_response)
      expect(elasticsearch_response).to receive(:records).ordered.and_return(records)
      expect(records).to receive(:total_count) { 0 }
      expect(records).to receive(:map)

      subject
    end
  end

  context 'when no parameters are given' do
    let(:filters) { VacancyFilters.new({}) }

    it 'does not call ElasticSearch' do
      expect(Vacancy).to_not receive(:__elasticsearch__)
      subject
    end
  end
end