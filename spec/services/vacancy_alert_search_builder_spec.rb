require 'rails_helper'

RSpec.describe VacancyAlertSearchBuilder do
  let(:from_date) { Time.zone.yesterday.strftime('%Y-%m-%d') }
  let(:to_date) { Time.zone.today.strftime('%Y-%m-%d') }

  describe '#call' do
    it 'builds a keyword search when a keyword is provided' do
      filters = OpenStruct.new(keyword: 'german')
      builder = described_class.new(filters: filters, from: from_date, to: to_date).call

      expected_hash = {
        multi_match: {
          query: 'german',
          fields: %w[job_title^3 subject.name first_supporting_subject.name second_supporting_subject.name],
          operator: 'and',
          fuzziness: 2,
          prefix_length: 1
        },
      }

      expect(builder).to be_a(Hash)
      expect(builder[:search_query][:bool][:must]).to include(expected_hash)
    end

    it 'builds a published status query by default' do
      filters = OpenStruct.new
      builder = described_class.new(filters: filters, from: from_date, to: to_date).call

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
      builder = described_class.new(filters: filters, from: from_date, to: to_date).call

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
    builder = described_class.new(filters: filters, from: from_date, to: to_date).call

    expected_sort_query = [{ publish_on: { order: :desc } }]

    expect(builder[:search_sort]).to eq(expected_sort_query)
  end

  it 'includes both the minimum and maximum salary when both are provided' do
    filters = OpenStruct.new(minimum_salary: 200, maximum_salary: 20000)
    builder = VacancyAlertSearchBuilder.new(filters: filters, from: from_date, to: to_date).call

    expected_hash = [
      {
        bool: {
          should: [
            {
              range: {
                minimum_salary: {
                  gte: 200
                }
              }
            }
          ]
        }
      },
      {
        bool: {
          should: [
            {
              bool: {
                should: [
                  {
                    range: {
                      maximum_salary: {
                        lte: 20000
                      }
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
    ]

    expect(builder).to be_a(Hash)
    expect(builder[:search_query][:bool][:must]).to include(expected_hash)
  end

  it 'includes only the maximum salary value when no minimum is provided' do
    filters = OpenStruct.new(minimum_salary: nil, maximum_salary: 20000)
    builder = VacancyAlertSearchBuilder.new(filters: filters, from: from_date, to: to_date).call

    expected_hash = [
      {
        bool: {
          should: [
            {
              range: {
                maximum_salary: {
                  lte: 20000
                }
              }
            }
          ]
        }
      },
      {
        bool: {
          should: [
            {
              bool: {
                should: [
                  {
                    range: {
                      maximum_salary: {
                        lte: 20000
                      }
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
    ]

    expect(builder).to be_a(Hash)
    expect(builder[:search_query][:bool][:must]).to include(expected_hash)
  end
end
