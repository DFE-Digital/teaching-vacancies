module VacancyJobSpecificationValidations
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    validates :job_title, :job_description, presence: true
    validates :job_title, length: { minimum: 4, maximum: 100 }, if: :job_title?
    validates :job_description, length: { minimum: 10, maximum: 50_000 }, if: :job_description?

    validates :minimum_salary, salary: { presence: true, minimum_value: false }
    validates :maximum_salary, salary: { presence: false }, if: :minimum_valid_and_maximum_salary_present?
    validate :maximum_salary_greater_than_minimum, if: :minimum_and_maximum_salary_present_and_valid?
    validates :working_pattern, presence: true
    validate :working_hours

    validate :starts_on_in_future?, if: :starts_on?
    validate :ends_on_in_future?, if: :ends_on?
    validate :starts_on_before_ends_on?

    validate :starts_on_before_closing_date, if: :starts_on?
    validate :ends_on_before_closing_date, if: :ends_on?
    validates_with DateFormatValidator, fields: %i[starts_on ends_on]
  end

  def starts_on_before_ends_on?
    errors.add(:starts_on, starts_on_after_ends_on_error) if starts_on? && ends_on? && starts_on > ends_on
  end

  def starts_on_after_ends_on_error
    I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.after_ends_on')
  end

  def starts_on_in_future?
    errors.add(:starts_on, starts_on_past_error) if starts_on.past?
  end

  def starts_on_past_error
    I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.past')
  end

  def starts_on_before_closing_date
    errors.add(:starts_on, starts_on_must_be_before_closing_date_error) if expires_on? && starts_on <= expires_on
  end

  def ends_on_before_closing_date
    errors.add(:ends_on, ends_on_must_be_before_closing_date_error) if expires_on? && ends_on <= expires_on
  end

  def starts_on_must_be_before_closing_date_error
    I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.before_expires_on')
  end

  def ends_on_must_be_before_closing_date_error
    I18n.t('activerecord.errors.models.vacancy.attributes.ends_on.before_expires_on')
  end

  def ends_on_in_future?
    errors.add(:ends_on, ends_on_past_error) if ends_on.past?
  end

  def ends_on_past_error
    I18n.t('activerecord.errors.models.vacancy.attributes.ends_on.past')
  end

  def minimum_valid_and_maximum_salary_present?
    errors[:minimum_salary].blank? && maximum_salary.present?
  end

  def minimum_and_maximum_salary_present_and_valid?
    errors[:minimum_salary].blank? && maximum_salary.present? && errors[:maximum_salary].blank?
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

  def maximum_salary_greater_than_minimum
    errors.add(:maximum_salary, maximum_salary_must_be_greater_than_minimum_error) if maximum_lower_than_minimum_salary?
  end

  def minimum_salary_greater_than_minimum_payscale
    errors.add(:minimum_salary, min_salary_lower_than_minimum_payscale_error) unless minimum_at_least_minimum_payscale?
  end

  # rubocop:disable Lint/Void
  def working_hours
    return if weekly_hours.blank?

    begin
      !!BigDecimal(weekly_hours)
      errors.add(:weekly_hours, negative_weekly_hours_error) if BigDecimal(weekly_hours).negative?
    rescue ArgumentError
      errors.add(:weekly_hours, invalid_weekly_hours_error)
    end
  end
  # rubocop:enable Lint/Void

  private

  def maximum_lower_than_minimum_salary?
    BigDecimal(minimum_salary) > BigDecimal(maximum_salary)
  rescue ArgumentError
    true
  end

  def maximum_salary_must_be_greater_than_minimum_error
    I18n.t('activerecord.errors.models.vacancy.attributes.maximum_salary.greater_than_minimum_salary')
  end

  def negative_weekly_hours_error
    I18n.t('activerecord.errors.models.vacancy.attributes.weekly_hours.negative')
  end

  def invalid_weekly_hours_error
    I18n.t('activerecord.errors.models.vacancy.attributes.weekly_hours.invalid')
  end
end
