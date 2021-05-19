class DateValidator < ActiveModel::EachValidator
  RESTRICTION_TYPES = {
    after: :>,
    before: :<,
    on_or_after: :>=,
    on_or_before: :<=,
  }.freeze

  DEFAULT_CHECK_VALUES = {
    today: Date.current,
    now: Time.current,
  }.freeze

  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :invalid) if value.blank? || value.is_a?(Hash)

    restrictions = RESTRICTION_TYPES.keys & options.keys

    restrictions.each do |restriction|
      operator = RESTRICTION_TYPES[restriction]
      restriction_option = options[restriction]

      if DEFAULT_CHECK_VALUES.key?(restriction_option)
        value_to_compare = DEFAULT_CHECK_VALUES[restriction_option]
      elsif record.respond_to?(restriction_option)
        value_to_compare = record.send(restriction_option)
      end

      next if value_to_compare.blank? || value_to_compare.is_a?(Hash)

      raise ArgumentError, "give me something to work with!!" unless value_to_compare

      record.errors.add(attribute, restriction) unless value.send(operator, value_to_compare)
    end
  end
end
