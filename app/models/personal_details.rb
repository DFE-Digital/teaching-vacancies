class PersonalDetails < ApplicationRecord
  belongs_to :jobseeker_profile

  has_encrypted :first_name, :last_name

  validates :jobseeker_profile, uniqueness: true

  validates :first_name, :last_name, presence: true
  validates :has_right_to_work_in_uk, inclusion: { in: [true, false] }

  self.ignored_columns += %i[phone_number_provided phone_number_ciphertext completed_steps]
end
