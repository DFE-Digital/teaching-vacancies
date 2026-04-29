class TrainingAndCpd < ApplicationRecord
  self.ignored_columns += %w[jobseeker_profile_id]

  belongs_to :job_application

  def duplicate
    dup.tap { |record| record.assign_attributes(job_application: nil) }
  end
end
