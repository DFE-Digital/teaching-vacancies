class SalaryValidator < ActiveModel::EachValidator
  include ApplicationHelper
  include ActiveSupport::Rescuable

  rescue_from ArgumentError, with: :invalid_format_message

  SALARY_FORMAT = /^\d+\.{0,1}\d{2}{0,1}$/
  MIN_SALARY_ALLOWED = PayScale.minimum_payscale_salary.freeze
  MAX_SALARY_ALLOWED = 2147483647

  def validate_each(record, attribute, value)
    return error_message(record, attribute, cant_be_blank_message) if value.blank? && check_presence?
    return error_message(record, attribute, invalid_format_message) if value[SALARY_FORMAT].nil?

    salary = converted_salary(value)
    return error_message(record, attribute, must_be_higher_than_min_allowed_message) if less_than_min_allowed?(salary)
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
    value < BigDecimal(MIN_SALARY_ALLOWED) if check_minimum?
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
           count: ActionController::Base.helpers.number_to_currency(MAX_SALARY_ALLOWED))
  end

  def must_be_higher_than_min_allowed_message
    I18n.t('errors.messages.salary.lower_than_minimum_payscale',
           minimum_salary: number_to_currency(MIN_SALARY_ALLOWED))
  end
end
