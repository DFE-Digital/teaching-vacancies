class JobSpecificationForm < VacancyForm
  delegate :expires_on, to: :vacancy

  include VacancyJobSpecificationValidations
end
