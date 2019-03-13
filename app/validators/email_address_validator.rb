class EmailAddressValidator < ActiveModel::EachValidator
  include ValidatorConcerns
  EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze

  def validate_each(record, attribute, value)
    return error_message(record, attribute, cant_be_blank_message) if check_presence? && value.blank?

    error_message(record, attribute, invalid_error_message) if value[EMAIL_FORMAT].nil?
  end

  private

  def invalid_error_message
    options[:message] || I18n.t('errors.messages.email.invalid')
  end
end

