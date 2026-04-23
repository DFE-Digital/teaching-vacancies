class TrainingAndCpd < ApplicationRecord
  belongs_to :job_application

  def duplicate
    dup.tap { |record| record.job_application = nil }
  end
end
