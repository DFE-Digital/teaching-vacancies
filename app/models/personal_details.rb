class PersonalDetails < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile

  has_encrypted :first_name, :last_name

  validates :jobseeker_profile, uniqueness: true

  self.ignored_columns += %i[phone_number_provided phone_number_ciphertext]

  def self.complete_steps(record)
    if record.first_name.present? && record.last_name.present?
      record.completed_steps["name"] = :completed
    end

    record.completed_steps["work"] = :completed unless record.has_right_to_work_in_uk.nil?
  end

  def complete?
    first_name.present? && last_name.present? && !has_right_to_work_in_uk.nil?
  end
end
