class ApplicationDetailsForm < VacancyForm
  delegate :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
           :publish_on_dd, :publish_on_mm, :publish_on_yyyy,
           :published?, :status, :publish_on_changed?, to: :vacancy

  include VacancyApplicationDetailValidations

  def disable_editing_publish_on?
    published? && vacancy.reload.publish_on.past?
  end

  def completed?
    application_link && contact_email && publish_on && expires_on
  end
end
