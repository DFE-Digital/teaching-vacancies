class Jobseekers::JobApplications::QuickApply
  def initialize(jobseeker, vacancy)
    @jobseeker = jobseeker
    @vacancy = vacancy
  end

  def job_application
    return new_job_application if @vacancy.has_uploaded_form?
    return new_job_application unless has_data_available_to_prefill_with?

    if previously_submitted_application?
      return Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication.new(jobseeker, new_job_application).call
    end

    Jobseekers::JobApplications::PrefillJobApplicationFromJobseekerProfile.new(jobseeker, new_job_application).call
  end

  private

  attr_reader :jobseeker, :vacancy

  def new_job_application
    @new_job_application = if @vacancy.has_uploaded_form?
                             jobseeker.uploaded_job_applications.create!(vacancy: vacancy)
                           else
                             jobseeker.native_job_applications.create!(vacancy: vacancy)
                           end
  end

  def previously_submitted_application?
    jobseeker.job_applications.not_draft.any?
  end

  def jobseeker_profile
    @jobseeker_profile ||= jobseeker.jobseeker_profile
  end

  def has_data_available_to_prefill_with?
    previously_submitted_application? || jobseeker_profile
  end
end
