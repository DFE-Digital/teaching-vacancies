class SubscriptionDecorator < Draper::Decorator
  delegate :email, :frequency, :search_criteria, :token, :id, :destroy!, :organisation, :to_key

  include ApplicationHelper
  include OrganisationsHelper

  SEARCH_CRITERIA_SORT_ORDER = %w[organisation_slug
                                  keyword
                                  location
                                  job_roles
                                  teaching_job_roles
                                  support_job_roles
                                  ect_statuses
                                  visa_sponsorship_availability
                                  subjects
                                  phases
                                  working_patterns].freeze

  def filtered_search_criteria
    @filtered_search_criteria ||= sorted_search_criteria.filter_map { |field, value| search_criteria_field(field, value) }
                                                        .reduce({}) { |hash, item| hash.merge(item) }
                                    .stringify_keys
  end

  private

  def sorted_search_criteria
    search_criteria.except("radius").sort_by { |(key, _)| SEARCH_CRITERIA_SORT_ORDER.find_index(key) || SEARCH_CRITERIA_SORT_ORDER.count }.to_h
  end

  def search_criteria_field(field, value)
    case field
    when "location"
      render_location_filter(value, search_criteria["radius"])
    when "ect_statuses"
      render_ect_statuses_filter(value)
    when "subjects"
      render_subjects_filter(value)
    when "working_patterns"
      render_working_patterns_filter(value)
    when "phases"
      render_phases_filter(value)
    when "organisation_slug"
      render_organisation_filter
    when "visa_sponsorship_availability"
      render_visas_filter(value)
    else
      job_roles_filter(field, value)
    end
  end

  def job_roles_filter(field, value)
    case field
    when "job_roles"
      render_legacy_job_roles_filter(value)
    when "teaching_job_roles"
      render_teaching_job_roles_filter(value)
    when "support_job_roles"
      render_support_job_roles_filter(value)
    else
      { "#{field}": value }
    end
  end

  def render_location_filter(location, radius)
    # simplecov:disable
    return if location.blank?

    # simplecov:enable

    if radius.present? && radius.to_s != "0"
      { location: I18n.t("subscriptions.location_with_radius", radius: radius, location: location) }
      # simplecov:disable
    elsif LocationPolygon.contain?(location)
      { location: I18n.t("subscriptions.location_in", location: location) }
      # simplecov:enable
    end
  end

  def render_legacy_job_roles_filter(value)
    { job_role: value.map { |role| I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{role}") }.join(", ") }
  end

  def render_teaching_job_roles_filter(value)
    { teaching_job_roles: value.map { |role| I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{role}") }.join(", ") }
  end

  def render_support_job_roles_filter(value)
    { support_job_roles: value.map { |role| I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.#{role}") }.join(", ") }
  end

  def render_visas_filter(value)
    { visa_sponsorship_availability: value.map { |option| I18n.t("helpers.label.publishers_job_listing_visa_sponsorship_form.visa_sponsorship_available_options.#{option}") }.join(", ") }
  end

  def render_ect_statuses_filter(values)
    values.filter_map { |option|
      # coverage of case statements without an effective 'else' doesn't work properly
      # simplecov:disable
      case option
      # simplecov:enable
      when "ect_suitable"
        { suitable_for_early_career_teachers: I18n.t("helpers.label.publishers_job_listing_about_the_role_form.ect_status_options.ect_suitable") }
      when "qts_not_needed"
        { fe_qts_required: I18n.t("helpers.label.publishers_job_listing_about_the_role_form.fe_role_qts_required_options.false") }
      end
    }.reduce({}) { |hash, item| hash.merge(item) }
  end

  def render_subjects_filter(value)
    { subjects: value.join(", ") }
  end

  def render_working_patterns_filter(value)
    { working_patterns: value.map { |role| I18n.t("helpers.label.publishers_job_listing_contract_information_form.working_patterns_options.#{role}") }.join(", ") }
  end

  def render_phases_filter(value)
    { education_phases: value.map { |phase| I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.#{phase}") }.join(", ") }
  end

  def render_organisation_filter
    { organisation_type_basic(organisation).titleize => organisation.name }
  end
end
