class TrainingAndCpd < ApplicationRecord
  self.ignored_columns += %w[jobseeker_profile_id]

  belongs_to :job_application
end
