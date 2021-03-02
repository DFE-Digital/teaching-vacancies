module Jobseekers::JobApplicationsHelper
  def application_link_path
    if job_application.nil?
      new_jobseekers_job_job_application_path(@vacancy.id)
    elsif jobseeker_application_status == "submitted"
      jobseekers_job_application_path(job_application)
    elsif jobseeker_application_status == "draft"
      jobseekers_job_application_review_path(job_application)
    end
  end

  def application_link_text
    if jobseeker_application_status.nil?
      "apply"
    elsif jobseeker_application_status == "submitted"
      "submitted"
    elsif jobseeker_application_status == "draft"
      "draft"
    end
  end

  def job_application
    current_jobseeker&.job_applications&.find_by(vacancy_id: @vacancy.id)
  end

  def jobseeker_application_status
    current_jobseeker&.job_applications&.find_by(vacancy_id: @vacancy.id)&.status
  end

  def jobseeker_has_applied?
    current_jobseeker&.job_applications&.find_by(vacancy_id: @vacancy.id)&.present?
  end
end
