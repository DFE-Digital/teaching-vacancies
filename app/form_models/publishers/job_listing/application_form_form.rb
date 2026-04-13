class Publishers::JobListing::ApplicationFormForm < Publishers::JobListing::VacancyForm
  validate :application_form_presence
  validate :existing_application_form_scan_safe
  validates :application_form, form_file: Vacancy::DOCUMENT_VALIDATION_OPTIONS.merge(skip_google_drive_virus_check: true)

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

  def existing_application_form_scan_safe
    return if application_form.present?
    return unless vacancy.application_form.attached?

    blob = vacancy.application_form.blob
    errors.add(:application_form, :unsafe_file) if blob.malware_scan_malicious? || blob.malware_scan_scan_error?
  end
end
