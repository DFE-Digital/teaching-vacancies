class SubscriptionPresenter < BasePresenter
  include ApplicationHelper

  SEARCH_CRITERIA_SORT_ORDER = %w[location radius keyword subject job_title minimum_salary maximum_salary
                                  working_pattern phases newly_qualified_teacher].freeze

  def filtered_search_criteria
    @filtered_search_criteria ||= sorted_search_criteria.each_with_object({}) do |(field, value), criteria|
      search_field = search_criteria_field(field, value)
      criteria.merge!(search_field) if search_field.present?
    end.stringify_keys
  end

  def to_row
    full_search_criteria.merge!(reference: reference)
                        .transform_values! do |value|
      value.is_a?(Array) ? value.join(', ') : value
    end
  end

  private

  def sorted_search_criteria
    search_criteria_to_h.sort_by do |(key, _)|
      SEARCH_CRITERIA_SORT_ORDER.find_index(key) || SEARCH_CRITERIA_SORT_ORDER.count
    end.to_h
  end

  def full_search_criteria
    available_filter_hash.merge(sorted_search_criteria.symbolize_keys)
  end

  def available_filter_hash
    Hash[VacancyAlertFilters::AVAILABLE_FILTERS.collect { |v| [v, nil] }]
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def search_criteria_field(field, value)
    return if field.eql?('radius')

    return render_location_filter(value, search_criteria_to_h['radius']) if field.eql?('location')
    return render_salary_filter(field, value) if field.ends_with?('_salary')
    return render_working_pattern_filter(value) if field.eql?('working_pattern')
    return render_phases_filter(value) if field.eql?('phases')
    return render_nqt_filter(value) if field.eql?('newly_qualified_teacher')

    { "#{field}": value }
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def render_location_filter(location, radius)
    return if location.empty? || radius.empty?

    { location: I18n.t('subscriptions.location_text', radius: radius, location: location) }
  end

  def render_salary_filter(field, value)
    { "#{field}": number_to_currency(value) }
  end

  def render_working_pattern_filter(value)
    { working_pattern: value.humanize }
  end

  def render_phases_filter(value)
    { phases: value.map(&:humanize).join(', ') }
  end

  def render_nqt_filter(value)
    { '': 'Suitable for NQTs' } if value.eql?('true')
  end
end
