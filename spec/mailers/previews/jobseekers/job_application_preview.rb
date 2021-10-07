# Documentation: app/mailers/previewing_emails.md
class Jobseekers::JobApplicationPreview < ActionMailer::Preview
  def application_shortlisted
    Jobseekers::JobApplicationMailer.application_shortlisted(JobApplication.shortlisted.sample)
  end

  def application_submitted_at_central_office
    application_submitted(Vacancy.central_office.first)
  end

  def application_submitted_at_multiple_schools
    application_submitted(Vacancy.at_multiple_schools.first)
  end

  def application_submitted_at_one_school
    application_submitted(Vacancy.at_one_school.first)
  end

  def application_unsuccessful
    Jobseekers::JobApplicationMailer.application_unsuccessful(JobApplication.unsuccessful.sample)
  end

  private

  def application_submitted(vacancy)
    job_application = JobApplication.find_by(jobseeker: Jobseeker.first, vacancy: vacancy) ||
                      FactoryBot.create(:job_application, :status_submitted, jobseeker: Jobseeker.first, vacancy: vacancy)
    Jobseekers::JobApplicationMailer.application_submitted(job_application)
  end
end
