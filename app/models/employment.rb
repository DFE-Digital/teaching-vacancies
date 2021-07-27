class Employment < ApplicationRecord
  belongs_to :job_application

  enum employment_type: { job: 0, break: 1 }
end
