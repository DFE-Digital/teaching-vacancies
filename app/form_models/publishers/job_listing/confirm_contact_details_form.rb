class Publishers::JobListing::ConfirmContactDetailsForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  validates :confirm_contact_email, presence: true
  attr_accessor(:confirm_contact_email)

  def self.fields
    %i[confirm_contact_email]
  end

  def params_to_save
    # confirm_contact_email is not a value that we store, only used for confirmation of contact_email, and navigation purposes, so we don't have any params to save here.
    {}
  end
end
