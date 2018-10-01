require 'geocoding'
class VacancySearchBuilder
  MIN_ALLOWED_RADIUS = 1

  def initialize(filters:, sort:, expired: false, status: :published)
    @keyword = filters.keyword.to_s.strip
    @working_pattern = filters.working_pattern
    @phase = filters.phase
    @newly_qualified_teacher = filters.newly_qualified_teacher
    @minimum_salary = filters.minimum_salary
    @maximum_salary = filters.maximum_salary
    @sort = sort
    @expired = expired
    @status = status

    return if filters.location.blank?
    @geocoded_location = Geocoding.new(filters.location).coordinates
    @radius = filters.radius.to_i.positive? ? filters.radius.to_i : MIN_ALLOWED_RADIUS
  end

  def call
    { search_query: search_query, search_sort: sort_query }
  end

  private

  def search_query
    query = {
      bool: {
        must: must_query_clause,
      }
    }
    query[:bool][:filter] = filters unless filters.empty?
    query
  end

  def must_query_clause
    [
      keyword_query,
      phase_query,
      newly_qualified_teacher_query,
      working_pattern_query,
      salary_query,
      expired_query,
      status_query,
      published_on_query
    ].compact
  end

  def filters
    @geocoded_location.present? ? location_geo_distance : {}
  end

  def keyword_query
    if @keyword.empty?
      match_all_hash
    else
      keyword_multi_match(@keyword)
    end
  end

  def location_geo_distance
    {
      geo_distance: {
        distance: "#{@radius}mi",
        coordinates: {
          lat: @geocoded_location.first,
          lon: @geocoded_location.last
        }
      }
    }
  end

  def expired_query
    return if @expired
    {
      range: {
        'expires_on': {
          'gte': 'now/d',
        },
      },
    }
  end

  def published_on_query
    return if @published_on
    {
      range: {
        'publish_on': {
          'lte': 'now/d',
        },
      },
    }
  end

  def status_query
    return if @status.blank?
    {
      bool: {
        filter: {
          terms: {
            status: [@status.to_s],
          },
        },
      },
    }
  end

  def working_pattern_query
    return if @working_pattern.blank?
    {
      bool: {
        filter: {
          terms: {
            working_pattern: [@working_pattern.to_s],
          },
        },
      },
    }
  end

  def newly_qualified_teacher_query
    return if @newly_qualified_teacher.blank?
    {
      bool: {
        filter: {
          term: {
            newly_qualified_teacher: @newly_qualified_teacher.to_s,
          },
        },
      },
    }
  end

  def phase_query
    return if @phase.blank?
    {
      bool: {
        filter: {
          terms: {
            'school.phase': [@phase.to_s],
          },
        }
      }
    }
  end

  def salary_query
    return if @minimum_salary.blank? && @maximum_salary.blank?
    return greater_than(:minimum_salary, @minimum_salary.to_i) if @maximum_salary.blank?
    return less_than_minimum_and_maximum_match if @minimum_salary.blank?

    [greater_than(:minimum_salary, @minimum_salary.to_i), less_than_maximum_salary_or_no_match]
  end

  def sort_query
    [{ @sort.column.to_sym => { order: @sort.order.to_sym } }]
  end

  def match_all_hash
    {
      match_all: {},
    }
  end

  def keyword_multi_match(keyword)
    {
      multi_match: {
        query: keyword,
        fields: %w[job_title^5 subject.name^3],
        operator: 'and',
        fuzziness: 1,
      },
    }
  end

  def greater_than(field, value)
    {
      range: {
        "#{field.to_s}": {
          'gte': value
        },
      },
    }
  end

  def less_than(field, value)
    {
      range: {
        "#{field.to_s}": {
          'lte': value,
        },
      },
    }
  end

  def less_than_maximum_salary_or_no_match
    {
      bool: {
        should: [
          less_than(:maximum_salary, @maximum_salary.to_i),
          bool: {
            must_not: {
              exists: {
                field: 'maximum_salary'
              }
            }
          }
        ]
      }
    }
  end

  def less_than_minimum_and_maximum_match
    [less_than(:minimum_salary, @maximum_salary.to_i), less_than_maximum_salary_or_no_match]
  end
end
