class JobPreferences < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker_profile
end
