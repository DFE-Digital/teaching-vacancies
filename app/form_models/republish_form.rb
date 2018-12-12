class RepublishForm < VacancyForm
  delegate :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
           :publish_on_dd, :publish_on_mm, :publish_on_yyyy,
           :starts_on_dd, :starts_on_mm, :starts_on_yyyy,
           :ends_on_dd, :ends_on_mm, :ends_on_yyyy,
           to: :vacancy

  include VacancyDateValidations
end
