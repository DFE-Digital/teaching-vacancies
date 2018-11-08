class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  delegate :total_pages, to: :model

  def share_url
    Rails.application.routes.url_helpers.job_url(model, protocol: 'https')
  end

  def salary_range(del = 'to')
    return number_to_currency(model.minimum_salary) if model.maximum_salary.blank?
    "#{number_to_currency(model.minimum_salary)} #{del} "\
    "#{number_to_currency(model.maximum_salary)}"\
    "#{model.part_time? ? ' per year pro rata' : ' per year'}"
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
    model.expires_on < Time.zone.today
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

  # rubocop:disable Rails/OutputSafety
  def flexible_working
    if model.flexible_working?
      mailto = mail_to(model.contact_email, model.school.name, class: 'govuk-link')
      @flexible_working = safe_join([I18n.t('jobs.flexible_working_info', mailto: mailto).html_safe])
    else
      'No'
    end
  end
  # rubocop:enable Rails/OutputSafety

  def working_pattern
    model.working_pattern.sub('_', ' ').humanize
  end

  def working_pattern_for_job_schema
    model.working_pattern.upcase
  end

  def review_page_title
    page_title = I18n.t('jobs.review_page_title', school: model.school.name)
    "#{model.errors.present? ? 'Error: ' : ''}#{page_title}"
  end

  def to_row
    [
      id,
      slug,
      created_at,
      status,
      publish_on,
      expires_on,
      starts_on,
      ends_on,
      weekly_hours,
      flexible_working,
      school.urn,
      school.county
    ]
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
