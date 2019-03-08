class DateFormatValidator < ActiveModel::Validator
  def validate(record)
    options[:fields].each do |field|
      date = record.send(field)
      next if date.blank?

      match = date.strftime('%Y-%m-%d').match(/^(?<y>\d*)\-/)

      record.errors.add(field, I18n.t('errors.messages.year_invalid')) if match[:y].length > 4
    end
  end
end
