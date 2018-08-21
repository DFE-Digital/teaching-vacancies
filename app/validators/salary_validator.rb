class SalaryValidator < ActiveModel::EachValidator
  include ApplicationHelper
  include ActiveSupport::Rescuable

  rescue_from ArgumentError, with: :invalid_format_message

  SALARY_FORMAT = /^\d+\.{0,1}\d{2}{0,1}$/
  MAX_SALARY_ALLOWED = 200000

  def validate_each(record, attribute, value)
    return error_message(record, attribute, cant_be_blank_message) if check_presence? && value.blank?
    return error_message(record, attribute, invalid_format_message) if value[SALARY_FORMAT].nil?

    salary = converted_salary(value)
    @record = record
    return error_message(record, attribute, lower_than_min_allowed_message) if less_than_min_allowed?(salary)
    return error_message(record, attribute, must_be_less_than_max_salary_message) if salary > MAX_SALARY_ALLOWED
  end

  private

  def error_message(record, attribute, message)
    record.errors[attribute] << message
  end

  def check_presence?
    options.key?(:presence) && options[:presence]
  end

  def check_minimum?
    options.key?(:minimum_value) && options[:minimum_value]
  end

  def less_than_min_allowed?(value)
    return false unless check_minimum?
    value < BigDecimal(@record.school_minimum_salary)
  end

  def converted_salary(value)
    BigDecimal(value)
  end

  def cant_be_blank_message
    I18n.t('errors.messages.blank')
  end

  def invalid_format_message
    I18n.t('errors.messages.salary.invalid_format')
  end

  def must_be_less_than_max_salary_message
    I18n.t('errors.messages.less_than_or_equal_to',
           count: number_to_currency(MAX_SALARY_ALLOWED, delimiter: ''))
  end

  def lower_than_min_allowed_message
    I18n.t('errors.messages.salary.lower_than_minimum_payscale',
           minimum_salary: number_to_currency(@record.school_minimum_salary, delimiter: ''))
  end
end
