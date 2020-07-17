class CopyVacancyForm < ImportantDatesForm
  include VacancyCopyValidations

  delegate :job_title, to: :vacancy
end
