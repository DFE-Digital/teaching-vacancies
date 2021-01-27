class Jobseekers::JobApplication::PersonalDetailsForm
  include ActiveModel::Model

  attr_accessor :building_and_street, :email_address, :first_name, :last_name, :national_insurance_number,
                :phone_number, :previous_names, :postcode, :teacher_reference_number, :town_or_city
end
