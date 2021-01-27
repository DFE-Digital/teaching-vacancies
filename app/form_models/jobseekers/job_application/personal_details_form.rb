class Jobseekers::JobApplication::PersonalDetailsForm
  include ActiveModel::Model

  attr_accessor :building_and_street, :email_address, :first_name, :last_name, :national_insurance_number,
                :phone_number, :previous_names, :postcode, :teacher_reference_number, :town_or_city

  validates :building_and_street, :email_address, :first_name, :last_name, :national_insurance_number,
            :phone_number, :postcode, :teacher_reference_number, :town_or_city, presence: true

  validates :email_address, format: { with: Devise.email_regexp }

  validates :national_insurance_number, format: { with: /\A\s*[a-zA-Z]{2}(?:\s*\d\s*){6}[a-zA-Z]?\s*\z/.freeze }

  validates :phone_number, format: { with: /\A\+?(?:\d\s?){10,12}\z/.freeze }

  validates :teacher_reference_number, presence: true, length: { maximum: 11 }
end
