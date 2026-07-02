class Publishers::JobListing::ApplicationLinkForm < Publishers::JobListing::JobListingForm
  validates :application_link, presence: true, url: { allow_blank: true }

  def self.fields
    %i[application_link]
  end
  attr_accessor(*fields)

  def params_to_save
    super.merge(enable_job_applications: false, receive_applications: :website)
  end
end
