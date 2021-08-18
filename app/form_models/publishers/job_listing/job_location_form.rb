class Publishers::JobListing::JobLocationForm < Publishers::JobListing::VacancyForm
  attr_accessor :job_location, :readable_job_location, :organisation_ids

  validates :job_location, presence: true

  def params_to_save
    {
      completed_steps: completed_steps,
      # Require users to complete entire steps before saving this param, not just the first part of a step,
      # because completing the first part of a step requires different responses in the second part:
      job_location: job_location == "central_office" ? job_location : nil,
      readable_job_location: readable_job_location,
      organisation_ids: organisation_ids,
    }.compact
  end
end
