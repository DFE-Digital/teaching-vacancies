class PersonalDetails < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile

  before_save :reset_phone_number

  def self.attributes_to_copy
    %w[
      first_name
      last_name
      phone_number
    ]
  end

  def self.before_save_on_prepare(record)
    record.phone_number_provided = record.phone_number.present?
  end

  def self.complete_steps(record)
    if record.first_name.present? && record.last_name.present?
      record.completed_steps["name"] = :completed
    end

    if record.phone_number_provided == false || record.phone_number.present?
      record.completed_steps["phone_number"] = :completed
    end
  end

  def reset_phone_number
    self.phone_number = nil unless phone_number_provided?
  end
end
