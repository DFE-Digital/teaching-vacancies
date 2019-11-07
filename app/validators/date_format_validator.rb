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
      record.errors.add(field, invalid_field_error(field))
    end
    record.errors.add(field, invalid_year_error(field)) if year.length > 4
  end

  def invalid_field_error(field)
    I18n.t("activerecord.errors.models.vacancy.attributes.#{field}.invalid")
  end

  def invalid_year_error(field)
    I18n.t("activerecord.errors.models.vacancy.attributes.#{field}.invalid_year")
  end
end
