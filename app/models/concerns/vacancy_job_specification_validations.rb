module VacancyJobSpecificationValidations
  extend ActiveSupport::Concern
  include ApplicationHelper
  include ActionView::Helpers::SanitizeHelper

  MAX_INTEGER = 2147483647

  included do
    validates :job_title, :job_description, :minimum_salary, :working_pattern, presence: true

    validates :minimum_salary,
              numericality: {
                less_than_or_equal_to: MAX_INTEGER,
                message: I18n.t('errors.messages.less_than_or_equal_to',
                                count: ActionController::Base.helpers.number_to_currency(MAX_INTEGER))
              },
              if: proc { |model| model.minimum_salary.present? }

    validates :maximum_salary,
              numericality: {
                less_than_or_equal_to: MAX_INTEGER,
                message: I18n.t('errors.messages.less_than_or_equal_to',
                                count: ActionController::Base.helpers.number_to_currency(MAX_INTEGER))
              },
              if: proc { |model| model.maximum_salary.present? }

    validate :minimum_salary_lower_than_maximum, :working_hours
    validate :minimum_salary_greater_than_minimum_payscale, if: proc { |a| a.minimum_salary.present? }
    validates :job_title, length: { minimum: 10, maximum: 50 },
                          if: proc { |model| model.job_title.present? }
    validates :job_description, length: { minimum: 10, maximum: 1000 },
                                if: proc { |model| model.job_description.present? }
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
