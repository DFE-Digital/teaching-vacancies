class ApplicationDetailsForm < VacancyForm
  validates :contact_email, :publish_on, :expires_on, presence: true
  validates :contact_email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  validate :validity_of_publish_on, :validity_of_expires_on

  delegate :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
           :publish_on_dd, :publish_on_mm, :publish_on_yyyy, to: :vacancy

  def validity_of_publish_on
    errors.add(:publish_on, 'can\'t be before today') if publish_on_after_today?
  end

  def validity_of_expires_on
    errors.add(:expires_on, 'can\'t be before the publish date') if expiry_date_less_than_publish_date?
  end

  private

  def expiry_date_less_than_publish_date?
    expires_on && publish_on && expires_on < publish_on
  end

  def publish_on_after_today?
    publish_on && publish_on < Time.zone.today
  end
end
