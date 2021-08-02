class Employment < ApplicationRecord
  belongs_to :job_application
  encrypts :organisation, :job_title, :main_duties

  enum employment_type: { job: 0, break: 1 }
end
