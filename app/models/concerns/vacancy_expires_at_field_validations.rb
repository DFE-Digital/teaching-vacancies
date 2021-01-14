module VacancyExpiresAtFieldValidations
  extend ActiveSupport::Concern

  included do
    validate :expires_at_must_not_be_blank, unless: proc { |v| validate_expires_at?(v) }
    validate :expires_at_must_be_in_correct_range, unless: proc { |v| validate_expires_at?(v) }
    validate :expires_at_meridiem_must_not_be_blank, unless: proc { |v| validate_expires_at?(v) }
  end

  private

  def expires_at_must_not_be_blank
    errors.add(:expires_at, I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.blank")) if
      expires_at_hh.blank? || expires_at_mm.blank?
  end

  def expires_at_must_be_in_correct_range
    errors.add(:expires_at, I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.wrong_format")) unless
      in_range?(expires_at_hh, 1, 12) && in_range?(expires_at_mm, 0, 59)
  end

  def expires_at_meridiem_must_not_be_blank
    errors.add(:expires_at, I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.must_be_am_pm")) if
      expires_at_meridiem.blank?
  end

  def in_range?(value, min, max)
    number?(value) && value.to_i >= min && value.to_i <= max
  end

  def number?(value)
    /\A[+-]?\d+\z/.match?(value.to_s)
  end

  def validate_expires_at?(vacancy)
    vacancy.expires_at.present? &&
      vacancy.expires_at_hh.blank? && vacancy.expires_at_mm.blank? && vacancy.expires_at_meridiem.blank?
  end
end
