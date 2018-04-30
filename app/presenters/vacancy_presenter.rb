class VacancyPresenter < BasePresenter
  include ActionView::Helpers::TextHelper

  delegate :total_pages, to: :model

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

  def pay_scale
    @pay_scale ||= model.pay_scale ? model.pay_scale.label : ''
  end

  def publish_today?
    model.publish_on == Time.zone.today
  end

  def flexible_working
    @flexible_working = model.flexible_working ? 'Yes' : 'No'
  end

  def working_pattern
    model.working_pattern.sub('_', ' ').humanize
  end

  def working_pattern_for_job_schema
    model.working_pattern.upcase
  end
end
