class Publishers::JobListing::ConfirmContactDetailsForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  attr_accessor(:confirm_contact_email)

  validates :confirm_contact_email, presence: true, if: -> { !@vacancy.contact_email_belongs_to_a_publisher? }

  class << self
    def fields
      %i[confirm_contact_email]
    end

    def load_form(model)
      # If the step is recorded as completed means they confirmed previously.
      if model.completed_steps.include?("confirm_contact_details")
        { confirm_contact_email: true }
      else
        {}
      end
    end
  end

  # confirm_contact_email is not a value that we store, only used for confirmation of contact_email, and navigation purposes.
  def params_to_save
    {}
  end
end
