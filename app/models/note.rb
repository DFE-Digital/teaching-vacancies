class Note < ApplicationRecord
  belongs_to :job_application
  belongs_to :publisher
end
