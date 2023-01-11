class Publishers::JobListing::ApplicationFormForm < Publishers::JobListing::VacancyForm
  validate :application_form_presence
  validates :application_form, form_file: true
  validates :application_email, presence: true
  validate :other_application_email_presence
  validate :other_application_email_valid

  def self.fields
    %i[application_email]
  end
  attr_accessor(:application_form, :application_form_staged_for_replacement, *fields)
  attr_writer(:other_application_email)

  def application_email
    return unless @vacancy.application_email || params[:application_email]

    if params[:application_email].present?
      return params[:application_email] if params[:application_email] == @current_publisher&.email

      return "other"
    end

    return @current_publisher&.email if @vacancy.application_email == @current_publisher&.email

    "other"
  end

  def other_application_email
    return params[:other_application_email] if params[:other_application_email]

    @vacancy.application_email unless @vacancy.application_email == @current_publisher&.email
  end

  def file_type
    :document
  end

  def content_types_allowed
    %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document].freeze
  end

  def file_size_limit
    10.megabytes
  end

  def valid_file_types
    %i[PDF DOC DOCX]
  end

  def params_to_save
    {
      application_email: params[:application_email] == "other" ? params[:other_application_email] : params[:application_email],
      completed_steps: params[:completed_steps],
    }
  end

  private

  def other_application_email_presence
    errors.add(:other_application_email, :blank) if params[:application_email] == "other" && params[:other_application_email].blank?
  end

  def other_application_email_valid
    return unless params[:other_application_email].present? && params[:application_email] == "other"

    errors.add(:other_application_email, :invalid) unless params[:other_application_email].match? URI::MailTo::EMAIL_REGEXP
  end

  def application_form_presence
    return if application_form.present?

    # See commit message for 1aa28cce3239c42b1af23d61ae08add3e8c51e5e for context
    errors.add(:application_form, :blank) if vacancy.application_form&.blank? || application_form_staged_for_replacement
  end
end
