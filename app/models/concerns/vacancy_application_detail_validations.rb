module VacancyApplicationDetailValidations
  extend ActiveSupport::Concern

  included do
    validates :publish_on, :expires_on, presence: true
    validates :contact_email, presence: true
    validates :contact_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i },
                              if: proc { |a| a.contact_email.present? }

    validate :validity_of_publish_on, :validity_of_expires_on
  end

  def validity_of_publish_on
    if publish_on_after_today?
      errors.add(:publish_on,
                 I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.before_today'))
    end
  end

  def validity_of_expires_on
    if expiry_date_less_than_publish_date?
      errors.add(:expires_on,
                 I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.before_publish_date'))
    end
  end

  private

  def expiry_date_less_than_publish_date?
    expires_on && publish_on && expires_on < publish_on
  end

  def publish_on_after_today?
    publish_on && publish_on < Time.zone.today
  end
end
