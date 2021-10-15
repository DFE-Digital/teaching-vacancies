class EmailAddressValidator < ActiveModel::EachValidator
  include ValidatorConcerns

  MAX_HOSTNAME_LENGTH = 253
  MAX_HOSTNAME_PART_LENGTH = 63
  MAX_OVERALL_LENGTH = 320
  MIN_HOSTNAME_PART_COUNT = 2

  HOSTNAME_PART_PATTERN = /^(xn|[a-z0-9]+)(-?-[a-z0-9]+)*$/i
  TLD_PATTERN = /^([a-z]{2,63}|xn--([a-z0-9]+-)*[a-z0-9]+)$/i

  EMAIL_ADDRESS_PATTERN = %r,^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~\\-]+@[^.@][^@\s]+$,

  class << self
    def valid?(email_address)
      !invalid?(email_address)
    end

    def invalid?(email_address)
      return if email_address.blank?

      email_address.include?("..") || !EMAIL_ADDRESS_PATTERN.match?(email_address) || wrong_length(email_address)
    end

    private

    def wrong_length(email_address)
      overall_length = email_address.length

      _local_part, hostname_parts, other_parts = email_address.split("@")

      hostname_parts = hostname_parts.split(".")
      tld_part = hostname_parts.last

      overall_length > MAX_OVERALL_LENGTH ||
        other_parts.present? ||
        hostname_parts.count < MIN_HOSTNAME_PART_COUNT ||
        hostname_parts.any? { |part| part.length > MAX_HOSTNAME_PART_LENGTH } ||
        hostname_parts.any? { |part| !HOSTNAME_PART_PATTERN.match?(part) } ||
        !TLD_PATTERN.match?(tld_part)
    end
  end

  def validate_each(record, attribute, value)
    if check_presence? && value.blank?
      error_message(record, attribute, blank_email_message)
    elsif self.class.invalid?(value)
      error_message(record, attribute, invalid_error_message)
    end
  end

  private

  def blank_email_message
    I18n.t("activerecord.errors.models.general_feedback.attributes.email.blank")
  end

  def invalid_error_message
    I18n.t("activerecord.errors.models.general_feedback.attributes.email.invalid")
  end
end
