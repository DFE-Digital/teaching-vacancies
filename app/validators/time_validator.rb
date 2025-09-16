class TimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?
    return record.errors.add(attribute, :invalid) if value.is_a?(String)
  end
end
