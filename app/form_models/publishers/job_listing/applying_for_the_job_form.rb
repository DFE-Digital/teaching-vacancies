class Publishers::JobListing::ApplyingForTheJobForm < Publishers::JobListing::JobListingForm
  validates :application_form_type, presence: true

  def self.fields
    %i[application_form_type]
  end
  attr_accessor(*fields)

  class << self
    # rubocop:disable Lint/UnusedMethodArgument
    def load_from_model(model, current_publisher:)
      attrs = if model.enable_job_applications
                { application_form_type: model.religion_type || "no_religion" }
              elsif model.enable_job_applications == false
                { application_form_type: "other" }
              else
                {}
              end
      new(attrs)
    end
    # rubocop:enable Lint/UnusedMethodArgument
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
end
