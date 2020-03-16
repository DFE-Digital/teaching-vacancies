class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  delegate :working_patterns, to: :model, prefix: true

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

  def salary_range(del = 'to')
    return number_to_currency(model.minimum_salary) if model.maximum_salary.blank?

    range = "#{number_to_currency(model.minimum_salary)} #{del} "
    range += "#{number_to_currency(model.maximum_salary)} "
    range +=
      if model.pro_rata_salary?
        I18n.t('jobs.per_year_pro_rata')
      elsif model.flexible_working?
        I18n.t('jobs.per_year_fte')
      else
        I18n.t('jobs.per_year')
      end
    range
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

  def pay_scale_range
    @pay_scale_range ||= begin
                           return '' if model.min_pay_scale.blank? && model.max_pay_scale.blank?
                           return "from #{model.min_pay_scale.label}" if only_min_pay_scale_present?
                           return "up to #{model.max_pay_scale.label}" if only_max_pay_scale_present?

                           pay_scale_range_label
                         end
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

  private

  def pay_scale_range_label
    "#{model.min_pay_scale.label} to #{model.max_pay_scale.label}"
  end

  def only_min_pay_scale_present?
    model.min_pay_scale.present? && model.max_pay_scale.blank?
  end

  def only_max_pay_scale_present?
    model.min_pay_scale.blank? && model.max_pay_scale.present?
  end
end
