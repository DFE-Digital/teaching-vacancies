class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  delegate :location, to: :school
  delegate :working_patterns, to: :model, prefix: true
  delegate :job_roles, to: :model, prefix: true

  def share_url(source: nil, medium: nil, campaign: nil, content: nil)
    params = { protocol: 'https' }
    if source.present?
      params.merge!(
        utm_source: source,
        utm_medium: medium,
        utm_campaign: campaign,
        utm_content: content,
      )
    end
    Rails.application.routes.url_helpers.job_url(model, params)
  end

  def job_summary
    simple_format(model.job_summary)
  end

  def about_organisation
    if model.about_organisation.present?
      simple_format(model.about_organisation)
    elsif school.description.present?
      simple_format(school.description)
    end
  end

  def school_visits
    simple_format(model.school_visits) if model.school_visits.present?
  end

  def how_to_apply
    simple_format(model.how_to_apply) if model.how_to_apply.present?
  end

  def education
    simple_format(model.education) if model.education.present?
  end

  def qualifications
    simple_format(model.qualifications) if model.qualifications.present?
  end

  def experience
    simple_format(model.experience) if model.experience.present?
  end

  def benefits
    simple_format(model.benefits) if model.benefits.present?
  end

  def expired?
    return model.expires_on < Time.zone.today if model.expiry_time.nil?

    model.expiry_time < Time.zone.now
  end

  def school
    @school ||= SchoolPresenter.new(model.school)
  end

  def publish_today?
    model.publish_on == Time.zone.today
  end

  def working_patterns?
    model_working_patterns.present?
  end

  def working_patterns
    return unless working_patterns?

    patterns = model_working_patterns.map do |working_pattern|
      Vacancy.human_attribute_name("working_patterns.#{working_pattern}").downcase
    end.join(', ')

    I18n.t("jobs.working_patterns_info_#{model_working_patterns.count > 1 ? 'many' : 'one'}", patterns: patterns)
        .capitalize
  end

  def working_patterns_for_job_schema
    return unless working_patterns?

    model_working_patterns.map(&:upcase).join(', ')
  end

  def to_row
    {
      id: id,
      slug: slug,
      created_at: created_at.to_s,
      status: status,
      publish_on: publish_on,
      expires_on: expires_on,
      starts_on: starts_on,
      flexible_working: flexible_working,
      school_urn: school.urn,
      school_county: school.county
    }
  end

  def job_title_and_school_or_school_group_name
    "#{job_title} at #{school_or_school_group_name}"
  end

  def show_job_roles
    model.job_roles&.join(', ')
  end

  def show_subjects
    model.subjects&.join(', ')
  end
end
