class TimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank?
      record.errors.add(attribute, :blank)
    elsif value.is_a?(String)
      record.errors.add(attribute, :invalid)
    end
  end
end
