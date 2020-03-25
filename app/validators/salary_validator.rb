class SalaryValidator < ActiveModel::EachValidator
  include ApplicationHelper
  include ActiveSupport::Rescuable
  include ValidatorConcerns

  rescue_from ArgumentError, with: :invalid_format_message

  SALARY_FORMAT = /^(\d+|\d{1,3}(,\d{3})*)(\.\d{2})?$/.freeze
  MIN_SALARY_ALLOWED = 0
  MAX_SALARY_LIMIT = 200000

  def validate_each(record, attribute, value)
    return error_message(record, attribute, blank_minimum_salary_message) if check_presence? && value.blank?
    return error_message(record, attribute, invalid_format_message(attribute)) if value[SALARY_FORMAT].nil?

    salary = converted_salary(value)
    return error_message(record, attribute, must_be_higher_than_min_allowed_message) if less_than_min_allowed?(salary)
    return error_message(record, attribute, must_be_less_than_max_salary_message(attribute)) \
      if salary >= MAX_SALARY_LIMIT
  end

  private

  def check_minimum?
    options.key?(:minimum_value) && options[:minimum_value]
  end

  def less_than_min_allowed?(value)
    value < BigDecimal(MIN_SALARY_ALLOWED) if check_minimum?
  end

  def converted_salary(value)
    BigDecimal(value)
  end

  def blank_minimum_salary_message
    I18n.t('activemodel.errors.models.job_specification_form.attributes.minimum_salary.blank')
  end

  def invalid_format_message(field_name)
    I18n.t('errors.messages.salary.invalid_format', salary: Vacancy.human_attribute_name(field_name))
  end

  def must_be_less_than_max_salary_message(field_name)
    I18n.t('activemodel.errors.models.job_specification_form.attributes.salary.more_than_maxiumum',
           salary: Vacancy.human_attribute_name(field_name),
           count: number_to_currency(MAX_SALARY_LIMIT, delimiter: ',')
          )
  end

  def must_be_higher_than_min_allowed_message
    I18n.t('errors.messages.salary.lower_than_minimum_payscale',
           minimum_salary: number_to_currency(MIN_SALARY_ALLOWED, delimiter: ''))
  end
end
