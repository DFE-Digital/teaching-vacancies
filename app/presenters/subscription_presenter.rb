class SubscriptionPresenter < BasePresenter
  include ApplicationHelper

  SEARCH_CRITERIA_SORT_ORDER = %i[location
                                  radius
                                  keyword
                                  subject
                                  job_title
                                  working_patterns
                                  phases
                                  newly_qualified_teacher].freeze

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
    Hash[SEARCH_CRITERIA_SORT_ORDER.collect { |v| [v, nil] }]
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def search_criteria_field(field, value)
    return if field.eql?('radius')
    return if field.eql?('location_category')

    return render_location_filter(
      search_criteria_to_h['location_category'], value, search_criteria_to_h['radius']
    ) if field.eql?('location')
    return render_working_patterns_filter(value) if field.eql?('working_patterns')
    return render_phases_filter(value) if field.eql?('phases')
    return render_nqt_filter(value) if field.eql?('newly_qualified_teacher')

    { "#{field}": value }
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def render_location_filter(location_category, location, radius)
    return if location.empty?

    return { location: I18n.t('subscriptions.location_category_text', location: location) } if location_category
    return { location: I18n.t('subscriptions.location_radius_text', radius: radius, location: location) } if radius
  end

  def render_working_patterns_filter(value)
    { working_patterns: value.map(&:humanize).join(', ').gsub(/Part time/, 'Part-time').gsub(/Full time/, 'Full-time') }
  end

  def render_phases_filter(value)
    { phases: value.map(&:humanize).join(', ') }
  end

  def render_nqt_filter(value)
    { '': 'Suitable for NQTs' } if value.eql?('true')
  end
end
