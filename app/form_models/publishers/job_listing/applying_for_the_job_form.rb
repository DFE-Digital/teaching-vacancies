class Publishers::JobListing::ApplyingForTheJobForm < Publishers::JobListing::VacancyForm
  before_validation :override_enable_job_applications!

  validates :enable_job_applications, inclusion: { in: [true, false, "true", "false"] }

  def self.fields
    %i[enable_job_applications]
  end
  attr_accessor(*fields)

  private

  def override_enable_job_applications!
    # If a publisher is signed in as an LA, we do not allow them to set the job applications feature.
    # This forces the field to be set so the validations pass when submitting the form (despite the
    # field not being there).
    # TODO: Remove params[:current_organisation].local_authority? (and conditional in view) when we start allowing applications feature for LAs

    # If a Publisher publishes a vacancy for a job role that does not allow enabling job applications
    # but then changes the job role to one that does, enable_job_applications is nil, meaning the validation
    # for this field does not pass. We want the validations for the enable_job_applications field to pass
    # to prevent an error from being displayed on the review page in this situation when validate_all_steps is run.
    self.enable_job_applications = false if (params[:current_organisation].local_authority? || vacancy.listed?) && enable_job_applications.blank?
  end
end
