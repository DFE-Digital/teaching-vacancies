require 'rails_helper'

RSpec.describe VacancyAlertSearchBuilder do
  let(:from_date) { Time.zone.yesterday.strftime('%Y-%m-%d') }
  let(:to_date) { Time.zone.today.strftime('%Y-%m-%d') }

  describe '#call' do
    it 'builds a published status query by default' do
      filters = OpenStruct.new
      builder = VacancyAlertSearchBuilder.new(filters: filters, from: from_date, to: to_date).call

      expected_hash = {
        bool: {
          filter: {
            terms: {
              status: ['published'],
            }
          }
        }
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'checks that the publish_on is between the specified date range' do
      filters = OpenStruct.new
      builder = VacancyAlertSearchBuilder.new(filters: filters, from: from_date, to: to_date).call

      expected_hash = {
        range: {
          publish_on: {
            gte: from_date,
            lt: to_date
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end
  end

  it 'sorts the results by publish_on date descending' do
    filters = OpenStruct.new
    builder = VacancyAlertSearchBuilder.new(filters: filters, from: from_date, to: to_date).call

    expected_sort_query = [{ publish_on: { order: :desc } }]

    expect(builder[:search_sort]).to eq(expected_sort_query)
  end
end
