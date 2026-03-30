class TrainingAndCpd < ApplicationRecord
  self.ignored_columns += [:jobseeker_profile_id]

  belongs_to :job_application

  def duplicate
    dup.tap { |record| record.job_application = nil }
  end
end
