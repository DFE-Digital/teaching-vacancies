class ApplicationDetailsForm < VacancyForm
  delegate :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
           :publish_on_dd, :publish_on_mm, :publish_on_yyyy, to: :vacancy

  include VacancyApplicationDetailValidations
end
