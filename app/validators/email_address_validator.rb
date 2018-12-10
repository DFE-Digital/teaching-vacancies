class EmailAddressValidator < ActiveModel::EachValidator
  EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  def validate_each(record, attribute, value)
    return record.errors[attribute] << cant_be_blank_message if check_presence? && value.blank?
    record.errors[attribute] << invalid_error_message(options) if value[EMAIL_FORMAT].nil?
  end

  private

  def invalid_error_message(options)
    options[:message] || I18n.t('errors.messages.email.invalid')
  end

  def check_presence?
    options.key?(:presence) && options[:presence]
  end

  def cant_be_blank_message
    I18n.t('errors.messages.blank')
  end
end

