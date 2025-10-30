class Publishers::JobListing::ContactDetailsForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  validates :contact_email, presence: true
  validate :other_contact_email_presence
  validate :other_contact_email_valid
  validates :contact_number_provided, inclusion: { in: [true, false] }
  validates :contact_number, presence: true, format: { with: /\A\+?(?:\d\s?){10,12}\z/ }, if: -> { contact_number_provided }

  FIELDS = %i[contact_email contact_number].freeze

  def self.fields
    FIELDS + %i[contact_number_provided]
  end
  attr_accessor(*FIELDS)
  attr_writer(:other_contact_email)

  attribute :contact_number_provided, :boolean

  def contact_email
    return unless @vacancy.contact_email || params[:contact_email]

    if params[:contact_email].present?
      return params[:contact_email] if params[:contact_email] == @current_publisher&.email

      return "other"
    end

    return @current_publisher&.email if @vacancy.contact_email == @current_publisher&.email

    "other"
  end

  def other_contact_email
    return params[:other_contact_email] if params[:other_contact_email]

    @vacancy.contact_email unless @vacancy.contact_email == @current_publisher&.email
  end

  def params_to_save
    {
      contact_email: params[:contact_email] == "other" ? params[:other_contact_email] : params[:contact_email],
      contact_number: (contact_number if contact_number_provided),
      contact_number_provided: contact_number_provided,
    }
  end

  # If we update the existing contact email to one that doesn't belong to a registered publisher, we want to make the user confirm it.
  # This will cause the confirm contact details to be removed from the vacancy completed steps so that the user has to go through it again.
  def steps_to_reset
    if params[:contact_email] == "other" && params[:other_contact_email] != @vacancy.contact_email && !Publisher.find_by(email: params[:other_contact_email])
      [:confirm_contact_details]
    else
      []
    end
  end

  private

  def other_contact_email_presence
    errors.add(:other_contact_email, :blank) if params[:contact_email] == "other" && params[:other_contact_email].blank?
  end

  def other_contact_email_valid
    return unless params[:other_contact_email].present? && params[:contact_email] == "other"

    errors.add(:other_contact_email, :invalid) unless params[:other_contact_email].match? URI::MailTo::EMAIL_REGEXP
  end
end
