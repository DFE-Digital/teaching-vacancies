class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  delegate :url_helpers, to: 'Rails.application.routes'
  delegate :total_pages, to: :model

  def share_url
    Rails.application.routes.url_helpers.job_url(model)
  end

  def salary_range(del = 'to')
    return number_to_currency(model.minimum_salary) if model.maximum_salary.blank?
    "#{number_to_currency(model.minimum_salary)} #{del} #{number_to_currency(model.maximum_salary)}"
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

  def flexible_working
    if model.flexible_working?
      mailto = mail_to(model.contact_email, model.school.name)
      @flexible_working = safe_join([I18n.t('jobs.flexible_working_info', mailto: mailto).html_safe])
    else
      'No'
    end
  end

  def working_pattern
    model.working_pattern.sub('_', ' ').humanize
  end

  def working_pattern_for_job_schema
    model.working_pattern.upcase
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
