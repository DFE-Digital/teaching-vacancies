class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  delegate :working_patterns, to: :model, prefix: true
  delegate :job_role, to: :model, prefix: true

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

  def job_description
    simple_format(model.job_description)
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

  def location
    @location ||= school.location
  end

  def expired?
    return model.expires_on < Time.zone.today if model.expiry_time.nil?

    model.expiry_time < Time.zone.now
  end

  def school
    @school ||= SchoolPresenter.new(model.school)
  end

  def main_subject
    @main_subject ||= model.subject ? model.subject.name : ''
  end

  def first_supporting_subject
    @first_supporting_subject ||= model.first_supporting_subject ? model.first_supporting_subject.name : ''
  end

  def second_supporting_subject
    @second_supporting_subject ||= model.second_supporting_subject ? model.second_supporting_subject.name : ''
  end

  def other_subjects
    @other_subjects ||= begin
        return '' if first_supporting_subject.blank? && second_supporting_subject.blank?
        return first_supporting_subject if only_first_supporting_subject_present?
        return second_supporting_subject if only_second_supporting_subject_present?

        supporting_subjects
      end
  end

  def only_first_supporting_subject_present?
    first_supporting_subject.present? && second_supporting_subject.blank?
  end

  def only_second_supporting_subject_present?
    second_supporting_subject.present? && first_supporting_subject.blank?
  end

  def supporting_subjects
    "#{first_supporting_subject}, #{second_supporting_subject}"
  end

  def any_subjects?
    main_subject.present? || other_subjects.present?
  end

  def subject_count
    [main_subject, first_supporting_subject, second_supporting_subject].count(&:present?)
  end

  def publish_today?
    model.publish_on == Time.zone.today
  end

  def newly_qualified_teacher
    model.newly_qualified_teacher? ? 'Suitable' : 'Not suitable'
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

  def review_page_title
    page_title = I18n.t('jobs.review_page_title', school: model.school.name)
    "#{model.errors.present? ? 'Error: ' : ''}#{page_title}"
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
      ends_on: ends_on,
      flexible_working: flexible_working,
      school_urn: school.urn,
      school_county: school.county
    }
  end

  def job_title_and_school
    "#{job_title} at #{school_name}"
  end

  def show_job_role
    model.job_role.join(', ')
  end
end
