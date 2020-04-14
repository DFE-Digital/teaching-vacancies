require 'geocoding'

class VacancySearchBuilder
  attr_accessor :filters,
                :keyword,
                :subject,
                :job_title,
                :working_patterns,
                :phases,
                :newly_qualified_teacher,
                :sort,
                :expired,
                :status

  def initialize(filters:, sort:, expired: false, status: :published)
    self.filters = filters
    self.keyword = filters.keyword.to_s.strip
    self.subject = filters.subject.to_s.strip
    self.job_title = filters.job_title.to_s.strip
    self.working_patterns = filters.working_patterns
    self.phases = filters.phases
    self.newly_qualified_teacher = filters.newly_qualified_teacher
    self.sort = sort
    self.expired = expired
    self.status = status
  end

  def call
    { search_query: search_query, search_sort: sort_query }
  end

  private

  def geocoded_location
    return if filters.location.blank? || filters.location_category_search?

    @geocoded_location ||= Geocoding.new(filters.location).coordinates
  end

  def radius
    filters.radius.to_i.positive? ? filters.radius.to_i : min_allowed_radius
  end

  def min_allowed_radius
    1
  end

  def location_filters
    geocoded_location.present? ? location_geo_distance : {}
  end

  def search_query
    query = {
      bool: {
        must: must_query_clause.presence || { match_all: {} }
      }
    }
    query[:bool][:filter] = location_filters unless location_filters.empty?
    query
  end

  def must_query_clause
    [
      keyword_query,
      subject_query,
      job_title_query,
      phase_query,
      newly_qualified_teacher_query,
      working_pattern_query,
      expired_query,
      status_query,
      published_on_query,
      location_category_query
    ].compact.uniq
  end

  def keyword_query
    return if keyword.blank?

    {
      multi_match: {
        query: keyword,
        type: 'best_fields',
        fields: %w[subject.name^3 first_supporting_subject.name^2 second_supporting_subject.name^2 job_title],
        operator: 'or',
        minimum_should_match: 1,
        fuzziness: 'AUTO'
      }
    }
  end

  def subject_query
    return if subject.blank?

    {
      multi_match: {
        query: subject,
        type: 'best_fields',
        fields: %w[subject.name^3 first_supporting_subject.name^2 second_supporting_subject.name^2 job_title],
        operator: 'or',
        minimum_should_match: 1,
        fuzziness: 'AUTO'
      }
    }
  end

  def job_title_query
    return if job_title.blank?

    {
      match: {
        job_title: {
          query: job_title,
          operator: 'and',
          fuzziness: 'AUTO',
        }
      }
    }
  end

  def location_geo_distance
    {
      geo_distance: {
        distance: "#{radius}mi",
        coordinates: {
          lat: geocoded_location.first,
          lon: geocoded_location.last
        }
      }
    }
  end

  def expired_query
    return if expired

    {
      range: {
        'expires_on': {
          'gte': 'now/d',
        },
      },
    }
  end

  def published_on_query
    {
      range: {
        'publish_on': {
          'lte': 'now/d',
        },
      },
    }
  end

  def status_query
    return if status.blank?

    {
      bool: {
        filter: {
          terms: {
            status: [status.to_s],
          },
        },
      },
    }
  end

  def working_pattern_query
    return if working_patterns.blank?

    {
      bool: {
        filter: {
          terms: {
            working_patterns: working_patterns.map(&:to_s),
          },
        },
      },
    }
  end

  def newly_qualified_teacher_query
    return if newly_qualified_teacher.blank?

    {
      bool: {
        filter: {
          term: {
            newly_qualified_teacher: newly_qualified_teacher.to_s,
          },
        },
      },
    }
  end

  def phase_query
    return if phases.blank?

    {
      bool: {
        filter: {
          terms: {
            'school.phase': phases.map(&:to_s),
          },
        }
      }
    }
  end

  def sort_query
    sort.present? ? [{ sort.column.to_sym => { order: sort.order.to_sym } }] : []
  end

  def location_category_query
    return unless filters.location_category_search?

    {
      multi_match: {
        query: filters.location,
        type: 'phrase',
        operator: 'and',
        fields: %w[school.region_name school.county school.town school.local_authority],
        minimum_should_match: 1
      }
    }
  end

  def match(field, value)
    {
      match: {
        field => value
      }
    }
  end
end
