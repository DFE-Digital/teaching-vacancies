class Jobseekers::JobApplication::PersonalDetailsForm
  include ActiveModel::Model

  attr_accessor :city, :first_name, :last_name, :national_insurance_number,
                :phone_number, :previous_names, :postcode, :street_address, :teacher_reference_number

  validates :city, :first_name, :last_name,
            :phone_number, :postcode, :street_address, :teacher_reference_number, presence: true

  validates :national_insurance_number, format: { with: /\A\s*[a-zA-Z]{2}(?:\s*\d\s*){6}[a-zA-Z]?\s*\z/.freeze }, allow_blank: true
  validates :phone_number, format: { with: /\A\+?(?:\d\s?){10,12}\z/.freeze }
  validates :teacher_reference_number, presence: true, length: { maximum: 11 }
end
