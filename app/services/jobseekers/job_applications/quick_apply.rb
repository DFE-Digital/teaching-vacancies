class Jobseekers::JobApplications::QuickApply
  def initialize(jobseeker, vacancy)
    @jobseeker = jobseeker
    @vacancy = vacancy
  end

  def job_application
    return new_job_application if @vacancy.uploaded_form?
    return new_job_application unless has_data_available_to_prefill_with?

    if previously_submitted_application?
      return Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication.new(jobseeker, new_job_application).call
    end

    Jobseekers::JobApplications::PrefillJobApplicationFromJobseekerProfile.new(jobseeker, new_job_application).call
  end

  private

  attr_reader :jobseeker, :vacancy

  def new_job_application
    vacancy.create_job_application_for(jobseeker)
  end

  def previously_submitted_application?
    jobseeker.has_submitted_native_job_application?
  end

  def jobseeker_profile
    @jobseeker_profile ||= jobseeker.jobseeker_profile
  end

  def has_data_available_to_prefill_with?
    previously_submitted_application? || jobseeker_profile.present?
  end
end
