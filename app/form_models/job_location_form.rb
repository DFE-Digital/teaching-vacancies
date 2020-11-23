class JobLocationForm < VacancyForm
  validates :job_location, presence: true

  def params_to_save
    {
      completed_step: params[:completed_step],
      job_location: params[:job_location] == "central_office" ? params[:job_location] : nil,
      readable_job_location: params[:readable_job_location],
      organisation_ids: params[:organisation_ids],
    }.compact
  end
end
