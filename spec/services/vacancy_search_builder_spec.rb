require 'rails_helper'

RSpec.describe VacancySearchBuilder do
  describe '#call' do
    it 'returns the default query with no parameters given' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new
      builder = described_class.new(filters: filters, sort: sort).call

      expected_hash = [
        {
          range: {
            expires_on: {
              gte: 'now/d'
            }
          }
        },
        {
          bool: {
            filter: {
              terms: {
                status: ['published']
              }
            }
          }
        },
        {
          range: {
            publish_on: {
              lte: 'now/d'
            }
          }
        }
      ]

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to eq(expected_hash)
    end

    it 'builds a subject search when a subject is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(subject: 'german')
      builder = described_class.new(filters: filters, sort: sort).call

      expected_hash = {
        multi_match: {
          query: 'german',
          type: 'best_fields',
          fields: %w[subject.name^3 first_supporting_subject.name^2 second_supporting_subject.name^2 job_title],
          operator: 'or',
          minimum_should_match: 1,
          fuzziness: 'AUTO'
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a job title search when a job title is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(job_title: 'teacher')
      builder = described_class.new(filters: filters, sort: sort).call

      expected_hash = {
        match: {
          job_title: {
            query: 'teacher',
            operator: 'and',
            fuzziness: 'AUTO'
          }
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a location query when a location is provided' do
      expect(Geocoding).to receive_message_chain(:new, :coordinates) { [54.32, -1.2332] }

      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(location: 'TR2 56D')
      builder = described_class.new(filters: filters, sort: sort).call

      expected_hash = {
        geo_distance: {
          distance: '1mi',
          coordinates: {
            lat: 54.32,
            lon: -1.2332
          }
        }
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:filter]).to include(expected_hash)
    end

    it 'builds a location category query when a location category is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(location: 'London', location_category_search?: true)
      builder = described_class.new(filters: filters, sort: sort).call

      expected_hash = {
        should: [
          { match: { 'school.region_name' => 'London' } },
          { match: { 'school.county' => 'London' } },
          { match: { 'school.local_authority' => 'London' } }
        ]
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must][3][:bool]).to include(expected_hash)
    end

    it 'builds a working pattern query when one is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(working_pattern: 'part_time')
      builder = described_class.new(filters: filters, sort: sort).call

      expected_hash = {
        bool: {
          filter: {
            terms: {
              working_patterns: ['part_time'],
            },
          },
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds an education phase query when one is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(phases: ['primary'])
      builder = described_class.new(filters: filters, sort: sort).call

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

    it 'builds a salary query when a minimum salary is provided' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(minimum_salary: 20000)
      builder = described_class.new(filters: filters, sort: sort).call

      expected_hash = {
        bool: {
          should: [
            {
              bool: {
                must: [
                  range: {
                    maximum_salary: {
                      gte: 20000
                    }
                  }
                ]
              }
            },
            {
              bool: {
                must_not: {
                  exists: {
                    field: 'maximum_salary'
                  }
                }
              }
            }
          ]
        }
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a published status query by default' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new
      builder = described_class.new(filters: filters, sort: sort).call

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

    it 'builds a published_on query by default' do
      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new
      builder = described_class.new(filters: filters, sort: sort).call

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
    builder = described_class.new(filters: filters, sort: sort, status: :draft).call

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
    builder = described_class.new(filters: filters, sort: sort).call

    expected_sort_query = [{ expires_on: { order: :desc } }]

    expect(builder[:search_sort]).to eq(expected_sort_query)
  end
end
