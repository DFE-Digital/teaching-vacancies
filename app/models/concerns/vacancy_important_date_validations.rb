module VacancyImportantDateValidations
  extend ActiveSupport::Concern

  included do
    validate :starts_on_in_future?, if: :starts_on?
    validate :ends_on_in_future?, if: :ends_on?
    validate :starts_on_before_ends_on?

    validate :starts_on_before_closing_date, if: :starts_on?
    validate :ends_on_before_closing_date, if: :ends_on?

    validates :publish_on, presence: true, unless: proc { |v| v.status == 'published' }
    validate :publish_on_must_not_be_in_the_past

    validates :expires_on, presence: true
    validate :validity_of_expires_on
  end

  def starts_on_before_ends_on?
    errors.add(:starts_on, starts_on_after_ends_on_error) if starts_on? && ends_on? && starts_on > ends_on
  end

  def starts_on_after_ends_on_error
    I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.after_ends_on')
  end

  def starts_on_in_future?
    errors.add(:starts_on, starts_on_past_error) if starts_on.past?
  end

  def starts_on_past_error
    I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.past')
  end

  def starts_on_before_closing_date
    errors.add(:starts_on, starts_on_must_be_before_closing_date_error) if expires_on? && starts_on <= expires_on
  end

  def ends_on_before_closing_date
    errors.add(:ends_on, ends_on_must_be_before_closing_date_error) if expires_on? && ends_on <= expires_on
  end

  def starts_on_must_be_before_closing_date_error
    I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.before_expires_on')
  end

  def ends_on_must_be_before_closing_date_error
    I18n.t('activerecord.errors.models.vacancy.attributes.ends_on.before_expires_on')
  end

  def ends_on_in_future?
    errors.add(:ends_on, ends_on_past_error) if ends_on.past?
  end

  def ends_on_past_error
    I18n.t('activerecord.errors.models.vacancy.attributes.ends_on.past')
  end

  def publish_on_must_not_be_in_the_past
    errors.add(:publish_on, publish_on_before_today_error) if publish_on_in_past?
  end

  def validity_of_expires_on
    errors.add(:expires_on, expires_on_before_publish_on_error) if expiry_date_less_than_publish_date?
  end

  def expiry_date_less_than_publish_date?
    expires_on && publish_on && expires_on < publish_on
  end

  def publish_on_in_past?
    publish_on && publish_on < Time.zone.today
  end

  def publish_on_before_today_error
    I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.before_today')
  end

  def expires_on_before_publish_on_error
    I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.before_publish_date')
  end
end
