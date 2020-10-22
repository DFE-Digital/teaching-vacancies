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
    @filtered_search_criteria ||= sorted_search_criteria.each_with_object({}) { |(field, value), criteria|
      search_field = search_criteria_field(field, value)
      criteria.merge!(search_field) if search_field.present?
    }.stringify_keys
  end

  def to_row
    full_search_criteria.transform_values! { |value| value.is_a?(Array) ? value.join(', ') : value }
  end

  def edit_url(source: nil, medium: nil, campaign: nil, content: nil)
    params = { protocol: 'https' }
    if source.present?
      params.merge!(
        utm_source: source,
        utm_medium: medium,
        utm_campaign: campaign,
        utm_content: content,
      )
    end
    Rails.application.routes.url_helpers.edit_subscription_url(model.token, params)
  end

private

  def sorted_search_criteria
    search_criteria_to_h.sort_by { |(key, _)|
      SEARCH_CRITERIA_SORT_ORDER.find_index(key) || SEARCH_CRITERIA_SORT_ORDER.count
    }.to_h
  end

  def full_search_criteria
    available_filter_hash.merge(sorted_search_criteria.symbolize_keys)
  end

  def available_filter_hash
    SEARCH_CRITERIA_SORT_ORDER.index_with { |_el| nil }
  end

  def search_criteria_field(field, value)
    return if field.eql?('radius')
    return if field.eql?('location_category')
    return if field.eql?('jobs_sort')

    if field.eql?('location')
      return render_location_filter(
        search_criteria_to_h['location_category'], value, search_criteria_to_h['radius']
      )
    end
    return render_job_roles_filter(value) if field.eql?('job_roles')
    return render_working_patterns_filter(value) if field.eql?('working_patterns')
    return render_phases_filter(value) if field.eql?('phases')
    return render_nqt_filter(value) if field.eql?('newly_qualified_teacher')

    { "#{field}": value }
  end

  def render_location_filter(location_category, location, radius)
    return if location.empty?

    return { location: I18n.t('subscriptions.location_category_text', location: location) } if location_category
    return { location: I18n.t('subscriptions.location_radius_text', radius: radius, location: location) } if radius
  end

  def render_job_roles_filter(value)
    { job_roles: value.map { |role| I18n.t("jobs.job_role_options.#{role}") }.join(', ') }
  end

  def render_working_patterns_filter(value)
    { working_patterns: value.map { |role| I18n.t("jobs.working_pattern_options.#{role}") }.join(', ') }
  end

  def render_phases_filter(value)
    { education_phases: value.map { |role| I18n.t("jobs.education_phase_options.#{role}") }.join(', ') }
  end

  def render_nqt_filter(value)
    { '': 'Suitable for NQTs' } if value.eql?('true')
  end
end
