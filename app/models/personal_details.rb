class PersonalDetails < ApplicationRecord
  belongs_to :jobseeker_profile

  before_save :reset_phone_number

  def reset_phone_number
    self.phone_number = nil unless phone_number_provided
  end
end
