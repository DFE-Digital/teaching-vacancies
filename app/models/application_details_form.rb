class ApplicationDetailsForm < VacancyForm

  validates :contact_email, :publish_on, presence: true

  validate :validity_of_publish_on, :validity_of_expiry_date

  delegate :expires_on_dd, :expires_on_mm, :expires_on_yyyy, to: :vacancy
  delegate :publish_on_dd, :publish_on_mm, :publish_on_yyyy, to: :vacancy

  def validity_of_publish_on
    errors.add(:publish_on, /can''t be before today/) if publish_on && publish_on < Time.zone.today
  end

  def validity_of_expiry_date
    errors.add(:expires_on, /can''t be blank/)  if expiry_date_incomplete?
  end

  private
  def expiry_date_incomplete?
    expires_on.blank? || expires_on_dd.blank? || expires_on_mm.blank? || expires_on_yyyy.blank?
  end
end
