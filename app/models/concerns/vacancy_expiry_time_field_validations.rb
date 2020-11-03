module VacancyExpiryTimeFieldValidations
  extend ActiveSupport::Concern

  included do
    validate :expiry_time_must_not_be_blank, unless: proc { |v| validate_expiry_time?(v) }
    validate :expiry_time_must_be_in_correct_range, unless: proc { |v| validate_expiry_time?(v) }
    validate :expiry_time_meridiem_must_not_be_blank, unless: proc { |v| validate_expiry_time?(v) }
  end

private

  def expiry_time_must_not_be_blank
    errors.add(:expiry_time, I18n.t("activerecord.errors.models.vacancy.attributes.expiry_time.blank")) if
      expiry_time_hh.blank? || expiry_time_mm.blank?
  end

  def expiry_time_must_be_in_correct_range
    errors.add(:expiry_time, I18n.t("activerecord.errors.models.vacancy.attributes.expiry_time.wrong_format")) unless
      in_range?(expiry_time_hh, 1, 12) && in_range?(expiry_time_mm, 0, 59)
  end

  def expiry_time_meridiem_must_not_be_blank
    errors.add(:expiry_time, I18n.t("activerecord.errors.models.vacancy.attributes.expiry_time.must_be_am_pm")) if
      expiry_time_meridiem.blank?
  end

  def in_range?(value, min, max)
    number?(value) && value.to_i >= min && value.to_i <= max
  end

  def number?(value)
    /\A[+-]?\d+\z/.match?(value.to_s)
  end

  def validate_expiry_time?(vacancy)
    vacancy.expiry_time.present? &&
      vacancy.expiry_time_hh.blank? && vacancy.expiry_time_mm.blank? && vacancy.expiry_time_meridiem.blank?
  end
end
