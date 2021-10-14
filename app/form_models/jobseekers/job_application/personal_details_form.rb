class Jobseekers::JobApplication::PersonalDetailsForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[city country email_address first_name last_name national_insurance_number phone_number previous_names postcode street_address teacher_reference_number]
  end
  attr_accessor(*fields)

  validates :city, :country, :email_address, :first_name, :last_name,
            :phone_number, :postcode, :street_address, presence: true

  validates :national_insurance_number, format: { with: /\A\s*[a-zA-Z]{2}(?:\s*\d\s*){6}[a-zA-Z]?\s*\z/ }, allow_blank: true
  validates :phone_number, format: { with: /\A\+?(?:\d\s?){10,13}\z/ }
  validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: true
  validates :email_address, email_address: true
end
