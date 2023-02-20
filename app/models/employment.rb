class Employment < ApplicationRecord
  belongs_to :job_application, optional: true
  belongs_to :jobseeker_profile, optional: true
  has_encrypted :organisation, :job_title, :main_duties

  enum employment_type: { job: 0, break: 1 }
end
