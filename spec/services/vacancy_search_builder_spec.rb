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
          fields: %w[job_title^5 subject.name^3 first_supporting_subject.name^3 second_supporting_subject.name^3],
          operator: 'and',
          fuzziness: 'AUTO'
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a location query when a location is provided' do
      expect(Geocoding).to receive_message_chain(:new, :coordinates) { [54.32, -1.2332] }

      sort = OpenStruct.new(column: :expires_on, order: :desc)
      filters = OpenStruct.new(location: 'TR2 56D')
      builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

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

    context 'salary query' do
      it 'only includes the minimum salary when no maximum is provided' do
        sort = OpenStruct.new(column: :expires_on, order: :desc)
        filters = OpenStruct.new(minimum_salary: 20000)
        builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

        expected_hash = {
          range: {
            minimum_salary: {
              gte: 20000
            }
          }
        }

        expect(builder).to be_a(Hash)
        expect(builder[:search_query][:bool][:must]).to include(expected_hash)
      end

      it 'includes both the minimum and maximum salary when both are provided' do
        sort = OpenStruct.new(column: :expires_on, order: :desc)
        filters = OpenStruct.new(minimum_salary: 200, maximum_salary: 20000)
        builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

        expected_hash = [
          {
            range: {
              minimum_salary: {
                gte: 200
              }
            }
          }, {
            bool: {
              should: [{
                range: {
                  maximum_salary: {
                    lte: 20000
                  }
                }
              }, {
                bool: {
                  must_not: {
                    exists: {
                      field: 'maximum_salary'
                    }
                  }
                }
              }]
            }
          }
        ]

        expect(builder).to be_a(Hash)
        expect(builder[:search_query][:bool][:must]).to include(expected_hash)
      end

      it 'includes only the maximum salary value when no minimum is provided' do
        sort = OpenStruct.new(column: :expires_on, order: :desc)
        filters = OpenStruct.new(minimum_salary: nil, maximum_salary: 20000)
        builder = VacancySearchBuilder.new(filters: filters, sort: sort).call

        expected_hash = [
          {
            range: {
              minimum_salary: {
                lte: 20000
              }
            }
          }, {
            bool: {
              should: [{
                range: {
                  maximum_salary: {
                    lte: 20000
                  }
                }
              }, {
                bool: {
                  must_not: {
                    exists: {
                      field: 'maximum_salary'
                    }
                  }
                }
              }]
            }
          }
        ]

        expect(builder).to be_a(Hash)
        expect(builder[:search_query][:bool][:must]).to include(expected_hash)
      end
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
