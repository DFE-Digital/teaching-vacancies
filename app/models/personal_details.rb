class PersonalDetails < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile

  before_save :reset_phone_number

  def self.prepare(...)
    super do |record|
      record.phone_number_provided = record.phone_number.present?
    end
  end

  def self.attributes_to_copy
    %w[
      first_name
      last_name
      phone_number
    ]
  end

  def reset_phone_number
    self.phone_number = nil unless phone_number_provided
  end
end
