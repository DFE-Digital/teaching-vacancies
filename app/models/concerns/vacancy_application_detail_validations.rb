module VacancyApplicationDetailValidations
  extend ActiveSupport::Concern

  included do
    validates :contact_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i },
                              if: proc { |a| a.contact_email.present? }
    validates :application_link, :contact_email, :expires_on, presence: true
    validates :application_link, url: true, if: proc { |v| v.application_link.present? }

    validates :publish_on, presence: true, if: proc { |v| !v.published? }
    validate :validity_of_publish_on
  end

  def validity_of_publish_on
    errors.add(:publish_on, publish_on_before_today_error) if publish_on_in_past? && publish_on_check?
  end

  def validity_of_expires_on
    errors.add(:expires_on, expires_on_before_publish_on_error) if expiry_date_less_than_publish_date?
  end

  def publish_on_check?
    published? && publish_on_change? || !published?
  end

  private

  def expiry_date_less_than_publish_date?
    expires_on && publish_on && expires_on < publish_on
  end

  def expires_on_before_publish_on_error
    I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.before_publish_date')
  end
end
