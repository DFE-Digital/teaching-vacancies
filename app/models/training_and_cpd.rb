class TrainingAndCpd < ApplicationRecord
  belongs_to :job_application

  def duplicate
    dup.tap { |record| record.assign_attributes(job_application: nil) }
  end
end
