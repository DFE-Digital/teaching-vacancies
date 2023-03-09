class JobPreferences < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile
  has_many :locations, dependent: :destroy
end
