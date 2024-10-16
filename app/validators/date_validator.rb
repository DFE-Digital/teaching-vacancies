class DateValidator < ActiveModel::EachValidator
  RESTRICTION_TYPES = {
    after: :>,
    before: :<,
    on_or_after: :>=,
    on_or_before: :<=,
  }.freeze

  def validate_each(record, attribute, value)
    # This 'constant' has to be dynamic otherwise validation takes place
    # against service boot time rather than current time
    default_check_values = {
      today: Date.current,
      now: Time.current,
      far_future: 2.years.from_now,
    }.freeze

    return record.errors.add(attribute, :blank) if value.blank?
    return record.errors.add(attribute, :invalid) if value.is_a?(Hash)

    restrictions = RESTRICTION_TYPES.keys & options.keys

    restrictions.each do |restriction|
      operator = RESTRICTION_TYPES[restriction]
      restriction_option = options[restriction]

      raise ArgumentError, "give me something to work with!!" unless
        default_check_values.key?(restriction_option) || record.respond_to?(restriction_option)

      if default_check_values.key?(restriction_option)
        value_to_compare = default_check_values[restriction_option]
      elsif record.respond_to?(restriction_option)
        value_to_compare = record.send(restriction_option)
      end

      next if value_to_compare.blank? || value_to_compare.is_a?(Hash)

      record.errors.add(attribute, restriction) unless value.send(operator, value_to_compare)
    end
  end
end
