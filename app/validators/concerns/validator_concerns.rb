module ValidatorConcerns
  extend ActiveSupport::Concern

  def check_presence?
    options.key?(:presence) && options[:presence]
  end

  private

  def error_message(record, attribute, message)
    record.errors[attribute] << message
  end

  def cant_be_blank_message
    I18n.t('errors.messages.blank')
  end
end
