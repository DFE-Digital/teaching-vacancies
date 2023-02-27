class JobPreferences < ApplicationRecord
  belongs_to :jobseeker_profile
  has_many :locations, dependent: :destroy
end
