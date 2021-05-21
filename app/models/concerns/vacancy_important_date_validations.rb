module VacancyImportantDateValidations
  extend ActiveSupport::Concern

  included do
    validates :publish_on, presence: true, unless: :published?
    validate :publish_on_must_not_be_before_today

    validates :expires_on, presence: true
    validate :expires_on_must_not_be_before_today
    validate :expires_on_must_not_be_before_publish_on

    validate :starts_on_must_not_be_before_today, if: proc { starts_on.present? }
    validate :starts_on_must_not_be_before_publish_on, if: proc { starts_on.present? }
    validate :starts_on_must_not_be_before_expires_on, if: proc { starts_on.present? }
    validate :starts_on_and_starts_asap_must_not_both_be_present
  end

  def publish_on_must_not_be_before_today
    errors.add(:publish_on, I18n.t("activerecord.errors.models.vacancy.attributes.publish_on.before_today")) if
      publish_on && publish_on < Date.current && (!vacancy.published? || publish_on != vacancy.publish_on)
  end

  def expires_on_must_not_be_before_today
    errors.add(:expires_on, I18n.t("activerecord.errors.models.vacancy.attributes.expires_on.before_today")) if
      expires_on && expires_on < Date.current && expires_on != vacancy.expires_on
  end

  def expires_on_must_not_be_before_publish_on
    errors.add(:expires_on, I18n.t("activerecord.errors.models.vacancy.attributes.expires_on.before_publish_on")) if
      expires_on && publish_on && expires_on < publish_on
  end

  def starts_on_must_not_be_before_today
    errors.add(:starts_on, I18n.t("activerecord.errors.models.vacancy.attributes.starts_on.before_today")) if
      starts_on && starts_on < Date.current && starts_on != vacancy.starts_on
  end

  def starts_on_must_not_be_before_publish_on
    errors.add(:starts_on, I18n.t("activerecord.errors.models.vacancy.attributes.starts_on.before_publish_on")) if
      starts_on && publish_on && starts_on < publish_on
  end

  def starts_on_must_not_be_before_expires_on
    errors.add(:starts_on, I18n.t("activerecord.errors.models.vacancy.attributes.starts_on.before_expires_on")) if
      starts_on && expires_on && starts_on < expires_on
  end

  def starts_on_and_starts_asap_must_not_both_be_present
    errors.add(:starts_on, I18n.t("activerecord.errors.models.vacancy.attributes.starts_on.multiple_start_dates")) if
      starts_on && starts_asap == "true"
  end
end
