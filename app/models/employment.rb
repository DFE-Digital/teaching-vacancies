class Employment < ApplicationRecord
  belongs_to :job_application
  encrypts :organisation, :job_title, :main_duties

  # remove this line after dropping unencrypted columns
  self.ignored_columns = %w[organisation job_title main_duties]

  enum employment_type: { job: 0, break: 1 }
end
