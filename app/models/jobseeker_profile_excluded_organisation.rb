class JobseekerProfileExcludedOrganisation < ApplicationRecord
  belongs_to :jobseeker_profile
  belongs_to :organisation
end
