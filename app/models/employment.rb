class Employment < ApplicationRecord
  belongs_to :job_application
  encrypts :organisation, :job_title, :main_duties, migrating: true
end
