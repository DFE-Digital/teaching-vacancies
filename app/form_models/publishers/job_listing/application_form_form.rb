class Publishers::JobListing::ApplicationFormForm < Publishers::JobListing::UploadBaseForm
  CONTENT_TYPES_ALLOWED = %w[
    application/pdf
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
  ].freeze

  validates :application_email, presence: true
  validate :other_application_email_presence
  validate :other_application_email_valid
  validate :application_form_presence

  def self.fields
    %i[application_email]
  end
  attr_accessor(:application_form, *fields)
  attr_writer(:other_application_email)

  def valid_application_form
    @valid_application_form ||= application_form if application_form &&
                                                    valid_file_size?(application_form) &&
                                                    valid_file_type?(application_form) &&
                                                    virus_free?(application_form)
  end

  def file_upload_field_name
    :application_form
  end

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

  def params_to_save
    {
      application_email: params[:application_email] == "other" ? params[:other_application_email] : params[:application_email],
    }
  end

  private

  def content_types_allowed
    CONTENT_TYPES_ALLOWED
  end

  def other_application_email_presence
    errors.add(:other_application_email, :blank) if params[:application_email] == "other" && params[:other_application_email].blank?
  end

  def other_application_email_valid
    return unless params[:other_application_email].present? && params[:application_email] == "other"

    errors.add(:other_application_email, :invalid) unless params[:other_application_email].match? URI::MailTo::EMAIL_REGEXP
  end

  def application_form_presence
    errors.add(:application_form, :blank) unless vacancy.application_form&.attached?
  end
end
