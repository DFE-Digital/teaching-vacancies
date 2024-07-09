class Jobseekers::JobApplications::QuickApply
  attr_reader :jobseeker, :vacancy

  def initialize(jobseeker, vacancy)
    @jobseeker = jobseeker
    @vacancy = vacancy
  end

  def job_application
    return new_job_application unless previously_submitted_application? || jobseeker_profile

    if previously_submitted_application?
      return Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication.new(jobseeker, vacancy, new_job_application).call
    end

    Jobseekers::JobApplications::PrefillJobApplicationFromJobseekerProfile.new(jobseeker, vacancy, new_job_application).call
  end

  private

  def new_job_application
    @new_job_application ||= jobseeker.job_applications.create(vacancy: vacancy)
  end

  def previously_submitted_application?
    jobseeker.job_applications.not_draft.any?
  end

  def jobseeker_profile
    @jobseeker_profile ||= jobseeker.jobseeker_profile
  end
end
