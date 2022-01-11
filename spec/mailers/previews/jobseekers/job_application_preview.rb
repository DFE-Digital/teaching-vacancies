# Documentation: app/mailers/previewing_emails.md
class Jobseekers::JobApplicationPreview < ActionMailer::Preview
  def application_shortlisted
    Jobseekers::JobApplicationMailer.application_shortlisted(JobApplication.shortlisted.sample)
  end

  def application_submitted_at_central_office
    job_application = JobApplication.submitted.first
    Jobseekers::JobApplicationMailer.application_submitted(job_application)
  end

  def application_submitted_at_multiple_schools
    job_application = JobApplication.submitted.first
    Jobseekers::JobApplicationMailer.application_submitted(job_application)
  end

  def application_submitted_at_one_school
    job_application = JobApplication.submitted.first
    Jobseekers::JobApplicationMailer.application_submitted(job_application)
  end

  def application_unsuccessful
    Jobseekers::JobApplicationMailer.application_unsuccessful(JobApplication.unsuccessful.sample)
  end

  def job_listing_ended_early
    job_application = JobApplication.find_by(jobseeker: Jobseeker.first)
    vacancy = job_application.vacancy

    Jobseekers::JobApplicationMailer.job_listing_ended_early(job_application, vacancy)
  end
end
