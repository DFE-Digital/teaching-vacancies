class Publishers::JobListing::ConfirmContactDetailsForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  validates :confirm_contact_email, presence: true, if: -> { unconfirmed_non_publisher_email? }
  attr_accessor(:confirm_contact_email)

  class << self
    # confirm_contact_email is not a value that we store, only used for confirmation of contact_email, and navigation purposes.
    def fields
      %i[confirm_contact_email]
    end

    def load_form(_model)
      {}
    end
  end

  def params_to_save
    {}
  end

  private

  def unconfirmed_non_publisher_email?
    !@vacancy.contact_email_belongs_to_a_publisher? && @vacancy.completed_steps.exclude?("confirm_contact_details")
  end
end
