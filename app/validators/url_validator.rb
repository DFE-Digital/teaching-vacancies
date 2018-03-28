class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    URI.parse(value).is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    record.errors[attribute] << I18n.t('errors.url.invalid')
  end
end
