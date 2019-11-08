class DateFormatValidator < ActiveModel::Validator
  def validate(record)
    options[:fields].each do |field|
      validate_date_fields(field, record)
    end
  end

  private

  def validate_date_fields(field, record)
    day = record.send(field.to_s + '_dd')
    month = record.send(field.to_s + '_mm')
    year = record.send(field.to_s + '_yyyy')
    return if day.blank? || month.blank? || year.blank?
    begin
      Date.parse("#{day}-#{month}-#{year}")
    rescue
      invalid_field_error(field, record)
    end
    invalid_field_error(field, record) unless year.length == 4
  end

  def invalid_field_error(field, record)
    record.errors.add(field,
      I18n.t("activerecord.errors.models.vacancy.attributes.#{field}.invalid")
    )
  end
end
