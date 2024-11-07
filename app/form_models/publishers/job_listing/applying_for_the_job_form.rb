class Publishers::JobListing::ApplyingForTheJobForm < Publishers::JobListing::VacancyForm
  before_validation :override_enable_job_applications!

  validates :enable_job_applications, inclusion: { in: [true, false, "true", "false"] }

  def self.fields
    %i[enable_job_applications]
  end
  attr_accessor(*fields)

  private

  def override_enable_job_applications!
    # If a Publisher publishes a vacancy for a job role that does not allow enabling job applications
    # but then changes the job role to one that does, enable_job_applications is nil, meaning the validation
    # for this field does not pass. We want the validations for the enable_job_applications field to pass
    # to prevent an error from being displayed on the review page in this situation when validate_all_steps is run.
    self.enable_job_applications = false if vacancy&.listed? && enable_job_applications.blank?
  end
end
