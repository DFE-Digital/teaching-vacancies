class Publishers::JobListing::ApplicationFormForm < Publishers::JobListing::VacancyForm
  validate :application_form_presence
  validates :application_form, form_file: Vacancy::DOCUMENT_VALIDATION_OPTIONS

  attr_accessor(:application_form, :application_form_staged_for_replacement)

  def params_to_save
    {
      completed_steps: params[:completed_steps],
    }
  end

  def self.fields
    []
  end

  private

  def application_form_presence
    return if application_form.present?

    # See commit message for 1aa28cce3239c42b1af23d61ae08add3e8c51e5e for context
    errors.add(:application_form, :blank) if vacancy.application_form.blank? || application_form_staged_for_replacement
  end
end
