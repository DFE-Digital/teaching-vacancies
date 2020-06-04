module VacancyExpiryTimeFieldValidations
  extend ActiveSupport::Concern

  included do
    validate :validate_time_format
  end

  private

  def validate_time_format
    return blank_error if expiry_time_field_blank?
    return wrong_format_error unless time_in_correct_range?
    return meridiem_error if expiry_time_meridiem.blank?
  end

  def expiry_time_field_blank?
    expiry_time_hh.blank? || expiry_time_mm.blank?
  end

  def time_in_correct_range?
    in_range?(expiry_time_hh, 1, 12) && in_range?(expiry_time_mm, 0, 59)
  end

  def in_range?(value, min, max)
    number?(value) && value.to_i >= min && value.to_i <= max
  end

  def number?(value)
    /\A[+-]?\d+\z/.match?(value)
  end

  def wrong_format_error
    errors.add(:expiry_time, I18n.t('activerecord.errors.models.vacancy.attributes.expiry_time.wrong_format'))
  end

  def blank_error
    errors.add(:expiry_time, I18n.t('activerecord.errors.models.vacancy.attributes.expiry_time.blank'))
  end

  def meridiem_error
    errors.add(:expiry_time, I18n.t('activerecord.errors.models.vacancy.attributes.expiry_time.must_be_am_pm'))
  end
end
