module VacancyJobSpecificationValidations
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    validates :job_title, :job_description, :headline,
              :minimum_salary, :working_pattern, presence: true

    validate :minimum_salary_lower_than_maximum, :working_hours
    validate :minimum_salary_greater_than_minimum_payscale, if: proc { |a| a.minimum_salary.present? }
    validates :job_title, length: { minimum: 10, maximum: 50 },
                          if: proc { |model| model.job_title.present? }
    validates :job_description, length: { minimum: 10, maximum: 1000 },
                                if: proc { |model| model.job_description.present? }
    validates :headline, length: { minimum: 10, maximum: 50 },
                         if: proc { |model| model.headline.present? }
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

  def minimum_at_least_minimum_payscale?
    minimum_salary >= minimum_payscale_salary
  end

  def minimum_payscale_salary
    @minimum_payscale_salar ||= PayScale.minimum_payscale_salary
  end

  def minimum_higher_than_maximum_salary?
    maximum_salary && minimum_salary > maximum_salary
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

  def min_salary_lower_than_minimum_payscale_error
    I18n.t('activerecord.errors.models.vacancy.attributes.minimum_salary.lower_than_minimum_payscale',
           minimum_salary: number_to_currency(minimum_payscale_salary))
  end
end
