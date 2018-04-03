require 'rails_helper'
RSpec.describe VacancySearchBuilder do
  describe '#call' do
    it 'returns the default keyword query with no parameters' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new
      builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

      expected_hash = {
        match_all: {},
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a keyword search when a keyword is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(keyword: 'german')
      builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

      expected_hash = {
        multi_match: {
          query: 'german',
          fields: %w[job_title^5 subject.name^3 headline^2],
          operator: 'and',
          fuzziness: 1
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a location query when a location is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(location: 'Devon')
      builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

      expected_hash = {
        multi_match: {
          query: 'Devon',
          fields: %w[school.postcode^5 school.name^2 school.town school.county school.address],
          operator: 'and',
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a working pattern query when one is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(working_pattern: 'part_time')
      builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

      expected_hash = {
        bool: {
          filter: {
            terms: {
              working_pattern: ['part_time'],
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds an education phase query when one is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(phase: 'primary')
      builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

      expected_hash = {
        bool: {
          filter: {
            terms: {
              'school.phase': ['primary'],
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a minimum salary query when one is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(minimum_salary: 20000)
      builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

      expected_hash = {
        range: {
          minimum_salary: {
            gte: 20000,
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a maximum salary query when one is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(maximum_salary: 20000)
      builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

      expected_hash = {
        range: {
          maximum_salary: {
            lt: 20000,
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a published status query by default' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new
      builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

      expected_hash = {
        bool: {
          filter: {
            terms: {
              status: ['published'],
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a published_on query by default' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new
      builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

      expected_hash = {
        range: {
          publish_on: {
            lte: 'now/d',
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end
  end

  it 'builds a status query by if one is provided' do
    sort = OpenStruct.new(column: :expires_on, order: :desc)
    filters = OpenStruct.new
    builder = VacancySearchBuilder.new(filters: filters, sort: sort, status: :draft).call

    expected_hash = {
      bool: {
        filter: {
          terms: {
            status: ['draft'],
          },
        },
      },
    }

    expect(builder).to be_a(Hash)
    expect(builder[:search_query][:bool][:must]).to include(expected_hash)
  end

  it 'builds a sort query' do
    sort = OpenStruct.new(column: :expires_on, order: :desc)
    filters = OpenStruct.new
    builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

    expected_sort_query = [{ expires_on: { order: :desc } }]

    expect(builder[:search_sort]).to eq(expected_sort_query)
  end
end
