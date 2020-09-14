module ValidatorConcerns
  extend ActiveSupport::Concern

  def check_presence?
    options.key?(:presence) && options[:presence]
  end

private

  def error_message(record, attribute, message)
    record.errors[attribute] << message
  end
end
