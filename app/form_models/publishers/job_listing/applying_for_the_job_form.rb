class Publishers::JobListing::ApplyingForTheJobForm < Publishers::JobListing::VacancyForm
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
        religion_type: "no_religion",
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
