# Preview all emails at http://localhost:3000/rails/mailers
class JobseekerPreview < ActionMailer::Preview
  def application_submitted_at_central_office
    application_submitted("7bfadb84-cf30-4121-88bd-a9f958440cc9")
  end

  def application_submitted_at_multiple_schools
    application_submitted("9910d184-5686-4ffc-9322-69aa150c19d3")
  end

  def application_submitted_at_one_school
    vacancy = School.first.vacancies.where(job_location: "at_one_school").sample
    application_submitted(vacancy.id)
  end

  def confirmation_instructions
    JobseekerMailer.confirmation_instructions(Jobseeker.first, "fake_token")
  end

  def email_changed
    JobseekerMailer.email_changed(Jobseeker.first)
  end

  def reset_password_instructions
    JobseekerMailer.reset_password_instructions(Jobseeker.first, "fake_token")
  end

  def unlock_instructions
    JobseekerMailer.reset_password_instructions(Jobseeker.first, "fake_token")
  end

  private

  def application_submitted(vacancy_id)
    seeded_vacancy = Vacancy.find(vacancy_id)
    job_application = JobApplication.find_by(jobseeker_id: Jobseeker.first.id, vacancy_id: seeded_vacancy.id) ||
                      FactoryBot.create(:job_application, jobseeker: Jobseeker.first, vacancy: seeded_vacancy)
    JobseekerMailer.application_submitted(job_application)
  end
end
