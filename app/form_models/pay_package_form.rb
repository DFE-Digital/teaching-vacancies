class PayPackageForm < VacancyForm
  include VacancyPayPackageValidations

  def completed?
    salary?
  end
end
