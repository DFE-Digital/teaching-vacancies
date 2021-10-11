# Documentation: app/mailers/previewing_emails.md
class Jobseekers::JobApplicationPreview < ActionMailer::Preview
  def application_shortlisted
    Jobseekers::JobApplicationMailer.application_shortlisted(JobApplication.shortlisted.sample)
  end

  def application_submitted_at_central_office
    job_application = JobApplication.find_by(jobseeker: Jobseeker.first, vacancy: Vacancy.central_office.first)
    Jobseekers::JobApplicationMailer.application_submitted(job_application)
  end

  def application_submitted_at_multiple_schools
    job_application = JobApplication.find_by(jobseeker: Jobseeker.first, vacancy: Vacancy.at_multiple_schools.first)
    Jobseekers::JobApplicationMailer.application_submitted(job_application)
  end

  def application_submitted_at_one_school
    job_application = JobApplication.find_by(jobseeker: Jobseeker.first, vacancy: Vacancy.at_one_school.first)
    Jobseekers::JobApplicationMailer.application_submitted(job_application)
  end

  def application_unsuccessful
    Jobseekers::JobApplicationMailer.application_unsuccessful(JobApplication.unsuccessful.sample)
  end
end
