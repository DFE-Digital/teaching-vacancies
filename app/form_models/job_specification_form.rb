class JobSpecificationForm < VacancyForm
  # rubocop:disable Lint/AmbiguousOperator
  delegate *['starts_on_yyyy', 'starts_on_mm', 'starts_on_dd',
             'ends_on_dd', 'ends_on_mm', 'ends_on_yyyy',
             'expires_on', 'working_patterns'].map { |attr| [attr, "#{attr}=", "#{attr}?"] }.flatten, to: :vacancy
  # rubocop:enable Lint/AmbiguousOperator

  include VacancyJobSpecificationValidations
end
