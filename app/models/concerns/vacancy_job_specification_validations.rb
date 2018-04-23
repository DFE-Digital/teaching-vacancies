module VacancyJobSpecificationValidations
  extend ActiveSupport::Concern
  include ApplicationHelper
  include ActionView::Helpers::SanitizeHelper

  included do
    validates :job_title, :job_description, :working_pattern, presence: true

    validates :minimum_salary, salary: { presence: true, minimum_value: true }
    validates :maximum_salary, salary: { presence: false }, if: :minimum_and_maximum_salary_present?
    validate :working_hours
    validate :minimum_salary_lower_than_maximum, if: :minimum_and_maximum_salary_present?
    validates :job_title, length: { minimum: 10, maximum: 50 }, if: :job_title?
    validates :job_description, length: { minimum: 10, maximum: 1000 }, if: :job_description?
  end

  def minimum_and_maximum_salary_present?
    minimum_salary.present? && maximum_salary.present?
  end

  def job_description=(value)
    super(sanitize(value))
  end

  def job_title=(value)
    super(sanitize(value, tags: []))
  end

  def benefits=(value)
    super(sanitize(value))
  end

  def minimum_salary_lower_than_maximum
    errors.add(:minimum_salary, min_salary_must_be_greater_than_max_error) if minimum_higher_than_maximum_salary?
  end

  def minimum_salary_greater_than_minimum_payscale
    errors.add(:minimum_salary, min_salary_lower_than_minimum_payscale_error) unless minimum_at_least_minimum_payscale?
  end

  def working_hours
    return if weekly_hours.blank?

    begin
      !!BigDecimal(weekly_hours)
      errors.add(:weekly_hours, negative_weekly_hours_error) if BigDecimal(weekly_hours).negative?
    rescue ArgumentError
      errors.add(:weekly_hours, invalid_weekly_hours_error)
    end
  end

  private

  def minimum_higher_than_maximum_salary?
    BigDecimal(minimum_salary) > BigDecimal(maximum_salary)
  rescue ArgumentError
    true
  end

  def min_salary_must_be_greater_than_max_error
    I18n.t('activerecord.errors.models.vacancy.attributes.minimum_salary.greater_than_maximum_salary')
  end

  def negative_weekly_hours_error
    I18n.t('activerecord.errors.models.vacancy.attributes.weekly_hours.negative')
  end

  def invalid_weekly_hours_error
    I18n.t('activerecord.errors.models.vacancy.attributes.weekly_hours.invalid')
  end
end
