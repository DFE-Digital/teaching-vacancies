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

  private

  def sorted_search_criteria
    search_criteria.sort_by { |(key, _)| SEARCH_CRITERIA_SORT_ORDER.find_index(key) || SEARCH_CRITERIA_SORT_ORDER.count }.to_h
  end

  def full_search_criteria
    available_filter_hash.merge(sorted_search_criteria.symbolize_keys)
  end

  def available_filter_hash
    SEARCH_CRITERIA_SORT_ORDER.index_with { |_el| nil }
  end

  def search_criteria_field(field, value)
    return if field.eql?("radius")
    return if field.eql?("jobs_sort")

    return render_location_filter(value, search_criteria["radius"]) if field.eql?("location")
    return render_job_roles_filter(value) if field.eql?("job_roles")
    return render_working_patterns_filter(value) if field.eql?("working_patterns")
    return render_phases_filter(value) if field.eql?("phases")
    return render_nqt_filter(value) if field.eql?("newly_qualified_teacher")

    { "#{field}": value }
  end

  def render_location_filter(location, radius)
    return if location.blank?

    return { location: I18n.t("subscriptions.location_polygon_text", location: location) } if LocationPolygon.include?(location)
    return { location: I18n.t("subscriptions.location_radius_text", radius: radius, location: location) } if radius
  end

  def render_job_roles_filter(value)
    { job_roles: value.map { |role| I18n.t("helpers.label.publishers_job_listing_job_details_form.job_roles_options.#{role}") }.join(", ") }
  end

  def render_working_patterns_filter(value)
    { working_patterns: value.map { |role| I18n.t("helpers.label.publishers_job_listing_working_patterns_form.working_patterns_options.#{role}") }.join(", ") }
  end

  def render_phases_filter(value)
    { education_phases: value.map { |role| I18n.t("jobs.education_phase_options.#{role}") }.join(", ") }
  end

  def render_nqt_filter(value)
    { '': "Suitable for NQTs" } if value.eql?("true")
  end
end
