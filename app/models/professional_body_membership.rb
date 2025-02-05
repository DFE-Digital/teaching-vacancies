class ProfessionalBodyMembership < ApplicationRecord
  belongs_to :jobseeker_profile, optional: true
  belongs_to :job_application, optional: true
end
