class Publishers::JobListing::JobLocationForm < Publishers::JobListing::VacancyForm
  attr_accessor :job_location, :readable_job_location, :organisation_ids

  validates :job_location, presence: true

  def self.fields
    %i[job_location]
  end

  def params_to_save
    {
      completed_steps: params[:completed_steps],
      job_location: params[:job_location] == "central_office" ? params[:job_location] : nil,
      readable_job_location: params[:readable_job_location],
      organisation_ids: params[:organisation_ids],
    }.compact
  end
end
