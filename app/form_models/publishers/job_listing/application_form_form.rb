class Publishers::JobListing::ApplicationFormForm < Publishers::JobListing::VacancyForm
  validate :application_form_presence
  validates :application_form, form_file: Vacancy::DOCUMENT_VALIDATION_OPTIONS

  attr_accessor :application_form

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

    errors.add(:application_form, :blank) if vacancy.application_form.blank?
  end
end
