class Publishers::JobListing::HowToReceiveApplicationsForm < Publishers::JobListing::JobListingForm
  validates :receive_applications, inclusion: { in: Vacancy.receive_applications.keys }

  def self.fields
    %i[receive_applications]
  end
  attr_accessor(*fields)

  def params_to_save
    super.merge(enable_job_applications: false)
  end
end
