class Publishers::JobListing::ApplyingForTheJobForm < Publishers::JobListing::VacancyForm
  # before_validation :override_enable_job_applications!

  # validates :enable_job_applications, inclusion: { in: [true, false, "true", "false"] }

  validates :application_form_type, presence: true

  def self.fields
    %i[application_form_type]
  end
  attr_accessor(*fields)

  class << self
    def load_form(model)
      if model.enable_job_applications
        { application_form_type: model.religion_type || "no_religion" }
      elsif model.enable_job_applications == false
        { application_form_type: "other" }
      else
        {}
      end
    end
  end

  def params_to_save
    if application_form_type == "other"
      {
        religion_type: nil,
        enable_job_applications: false,
      }
    else
      {
        religion_type: application_form_type,
        enable_job_applications: true,
      }
    end
  end

  # def override_enable_job_applications!
  #   # If a Publisher publishes a vacancy for a job role that does not allow enabling job applications
  #   # but then changes the job role to one that does, enable_job_applications is nil, meaning the validation
  #   # for this field does not pass. We want the validations for the enable_job_applications field to pass
  #   # to prevent an error from being displayed on the review page in this situation when validate_all_steps is run.
  #   self.enable_job_applications = false if vacancy&.listed? && enable_job_applications.blank?
  # end
end
