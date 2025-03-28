class BatchEmailJobApplication < ApplicationRecord
  belongs_to :batch_email
  belongs_to :job_application
end
