class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  delegate :location, to: :organisation
  delegate :working_patterns, to: :model, prefix: true
  delegate :job_roles, to: :model, prefix: true

  def share_url(utm_source: nil, utm_medium: nil, utm_campaign: nil, utm_content: nil)
    params = {}
    if utm_source.present?
      params.merge!(
        utm_source: utm_source,
        utm_medium: utm_medium,
        utm_campaign: utm_campaign,
        utm_content: utm_content,
      )
    end
    Rails.application.routes.url_helpers.job_url(model, params)
  end

  def job_advert
    simple_format(model.job_advert)
  end

  def about_school
    simple_format(model.about_school)
  end

  def school_visits
    simple_format(model.school_visits) if model.school_visits.present?
  end

  def how_to_apply
    simple_format(model.how_to_apply) if model.how_to_apply.present?
  end

  def benefits
    simple_format(model.benefits) if model.benefits.present?
  end

  def expired?
    model.expires_at < Time.current
  end

  def publish_today?
    model.publish_on == Date.current
  end

  def working_patterns?
    model_working_patterns.present?
  end

  def working_patterns
    return unless working_patterns?

    patterns = model_working_patterns.map { |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ")

    I18n.t("jobs.working_patterns_info_#{model_working_patterns.count > 1 ? 'many' : 'one'}", patterns: patterns)
        .capitalize
  end

  def working_patterns_for_job_schema
    return unless working_patterns?

    model_working_patterns.compact.map(&:upcase).join(", ")
  end

  def to_row
    {
      id: id,
      slug: slug,
      created_at: created_at.to_s,
      status: status,
      publish_on: publish_on,
      expires_at: expires_at,
      starts_on: starts_on,
      school_urn: organisation.urn,
      school_county: organisation.county,
    }
  end

  def show_job_roles
    return unless model.job_roles

    model.job_roles.map { |job_role| I18n.t("helpers.label.publishers_job_listing_job_details_form.job_roles_options.#{job_role}") }.join(", ")
  end

  def show_subjects
    model.subjects&.join(", ")
  end

  def contract_type_with_duration
    type = model.contract_type ? I18n.t("helpers.label.publishers_job_listing_job_details_form.contract_type_options.#{model.contract_type}") : nil
    duration = model.fixed_term? ? "(#{model.contract_type_duration})" : nil
    [type, duration].compact.join(" ")
  end
end
