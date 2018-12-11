class SubscriptionPresenter < BasePresenter
  include ApplicationHelper

  def filtered_search_criteria
    @filtered_search_criteria ||= search_criteria_to_h.each_with_object({}) do |(field, value), criteria|
      search_field = add_search_criteria_field(field, value)
      criteria.merge!(search_field) if search_field.present?
    end.stringify_keys
  end

  private

  def add_search_criteria_field(field, value)
    return if field.eql?('radius')

    return render_location_filter(value, search_criteria_to_h['radius']) if field.eql?('location')
    return render_salary_filter(field, value) if field.ends_with?('_salary')
    return render_nqt_filter(value) if field.eql?('newly_qualified_teacher')

    field.eql?('working_pattern') ? render_working_pattern_filter(value) : { "#{field}": search_criteria_to_h[field] }
  end

  def render_location_filter(location, radius)
    return if location.empty? || radius.empty?
    { location: I18n.t('subscriptions.location_text', radius: radius, location: location) }
  end

  def render_salary_filter(field, value)
    { "#{field}": number_to_currency(value) }
  end

  def render_nqt_filter(value)
    { '': 'Suitable for NQTs' } if value.eql?('true')
  end

  def render_working_pattern_filter(value)
    { working_pattern: value.humanize }
  end
end
