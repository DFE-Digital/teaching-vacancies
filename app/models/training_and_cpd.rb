class TrainingAndCpd < ApplicationRecord
  belongs_to :jobseeker_profile, optional: true
  belongs_to :job_application, optional: true

  def duplicate
    self.class.new(
      name:,
      provider:,
      grade:,
      year_awarded:,
    )
  end
end
