class JobSpecificationForm < VacancyForm
  delegate ['starts_on_yyyy', 'starts_on_mm', 'starts_on_dd',
            'ends_on_dd', 'ends_on_mm', 'ends_on_yyyy'].map { |attr| [attr, "#{attr}="] }.flatten, to: :vacancy

  include VacancyJobSpecificationValidations
end
