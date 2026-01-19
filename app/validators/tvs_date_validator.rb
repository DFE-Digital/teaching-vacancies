class TvsDateValidator < ActiveModel::EachValidator
  RESTRICTION_TYPES = {
    after: :>,
    before: :<,
    on_or_after: :>=,
    on_or_before: :<=,
  }.freeze

  DEFAULT_CHECK_VALUES = {
    today: -> { Date.current },
    now: -> { Time.current },
    far_future: -> { 2.years.from_now },
  }.freeze

  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?
    return record.errors.add(attribute, :invalid) if value.is_a?(Hash)

    restrictions = RESTRICTION_TYPES.keys & options.keys

    restrictions.each do |restriction|
      operator = RESTRICTION_TYPES[restriction]
      restriction_option = options[restriction]

      raise ArgumentError, "give me something to work with!!" unless
        DEFAULT_CHECK_VALUES.key?(restriction_option) || record.respond_to?(restriction_option)

      if DEFAULT_CHECK_VALUES.key?(restriction_option)
        value_to_compare = DEFAULT_CHECK_VALUES[restriction_option].call
      elsif record.respond_to?(restriction_option)
        value_to_compare = record.send(restriction_option)
      end

      next if value_to_compare.blank? || value_to_compare.is_a?(Hash)

      record.errors.add(attribute, restriction) unless value.send(operator, value_to_compare)
    end
  end
end
