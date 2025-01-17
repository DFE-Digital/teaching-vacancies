class ProfessionalBodyMembership < ApplicationRecord
  belongs_to :jobseeker_profile, optional: true
end
