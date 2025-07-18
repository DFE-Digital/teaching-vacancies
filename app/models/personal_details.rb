class PersonalDetails < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile

  before_save :reset_phone_number

  has_encrypted :first_name, :last_name, :phone_number

  validates :jobseeker_profile, uniqueness: true

  def self.attributes_to_copy
    %w[
      first_name
      last_name
      phone_number
      has_right_to_work_in_uk
    ]
  end

  def self.before_save_on_prepare(record)
    record.phone_number_provided = record.phone_number.present?
  end

  def self.complete_steps(record)
    if record.first_name.present? && record.last_name.present?
      record.completed_steps["name"] = :completed
    end

    record.completed_steps["phone_number"] = :completed if record.phone_number_provided == false || record.phone_number.present?
    record.completed_steps["work"] = :completed unless record.has_right_to_work_in_uk.nil?
  end

  def reset_phone_number
    self.phone_number = nil unless phone_number_provided?
  end

  def complete?
    first_name.present? && last_name.present? && (!phone_number_provided? || phone_number.present?) && !has_right_to_work_in_uk.nil?
  end
end
