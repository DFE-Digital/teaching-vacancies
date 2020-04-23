module VacancyApplicationDetailValidations
  extend ActiveSupport::Concern

  included do
    validates :contact_email, presence: true
    validates :contact_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, if: :contact_email?

    validates :application_link, presence: true
    validates :application_link, url: true, if: :application_link?

    validates :publish_on, presence: true, unless: proc { |v| v.status == 'published' }
    validate :publish_on_must_not_be_in_the_past

    validates :expires_on, presence: true
    validate :validity_of_expires_on
  end

  def publish_on_must_not_be_in_the_past
    errors.add(:publish_on, publish_on_before_today_error) if publish_on_in_past? && publish_on_changed?
  end

  def validity_of_expires_on
    errors.add(:expires_on, expires_on_before_publish_on_error) if expiry_date_less_than_publish_date?
  end

  private

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
