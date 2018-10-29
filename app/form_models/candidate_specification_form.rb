class CandidateSpecificationForm < VacancyForm
  include VacancyCandidateSpecificationValidations

  def completed?
    valid?
  end
end
