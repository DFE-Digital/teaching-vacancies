class VacancySearchBuilder
  def initialize(filters:, sort:, expired: false, status: :published)
    @keyword = filters.keyword.to_s.strip
    @location = filters.location.to_s.strip
    @geocoded_location ||= Geocoder.coordinates(@location, params: { countrycodes: 'uk' }) if @location.present?
    @radius = filters.radius.to_i
    @working_pattern = filters.working_pattern
    @phase = filters.phase
    @minimum_salary = filters.minimum_salary
    @maximum_salary = filters.maximum_salary
    @sort = sort
    @expired = expired
    @status = status
  end

  def call
    keyword_query = keyword_build
    working_pattern_query = working_pattern_build
    phase_query = phase_build
    minimum_salary_query = minimum_salary_build
    maximum_salary_query = maximum_salary_build
    expired_query = expired_build
    published_query = published_on_build
    status_query = status_build
    sort_query = sort_build

    joined_query = [
      keyword_query,
      phase_query,
      working_pattern_query,
      minimum_salary_query,
      maximum_salary_query,
      expired_query,
      status_query,
      published_query
    ].compact

    query = {
      bool: {
        must: joined_query,
        filter: location_geo_distance
      }
    }

    { search_query: query, search_sort: sort_query }
  end

  private

  def keyword_build
    if @keyword.empty?
      match_all_hash
    else
      keyword_multi_match(@keyword)
    end
  end

  def location_geo_distance
    return if @geocoded_location.nil?
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

  def expired_build
    return if @expired
    {
      range: {
        'expires_on': {
          'gte': 'now/d',
        },
      },
    }
  end

  def published_on_build
    return if @published_on
    {
      range: {
        'publish_on': {
          'lte': 'now/d',
        },
      },
    }
  end

  def status_build
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

  def working_pattern_build
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

  def phase_build
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

  def minimum_salary_build
    return if @minimum_salary.blank?
    {
      range: {
        'minimum_salary': {
          'gte': @minimum_salary.to_i,
        },
      },
    }
  end

  def maximum_salary_build
    return if @maximum_salary.blank?
    {
      range: {
        'maximum_salary': {
          'lt': @maximum_salary.to_i,
        },
      },
    }
  end

  def sort_build
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
end
