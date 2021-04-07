class Jobseekers::JobApplications::QuickApply
  include Jobseekers::Wizardable

  attr_reader :jobseeker, :vacancy

  def initialize(jobseeker, vacancy)
    @jobseeker = jobseeker
    @vacancy = vacancy
  end

  def job_application
    new_job_application.assign_attributes(recent_job_application.slice(*attributes_to_copy).merge(completed_steps: completed_steps))
    copy_qualifications
    copy_employments
    copy_references
    new_job_application.save
    new_job_application
  end

  private

  def new_job_application
    @new_job_application ||= jobseeker.job_applications.create(vacancy: vacancy)
  end

  def recent_job_application
    @recent_job_application ||= jobseeker.job_applications.not_draft.order(submitted_at: :desc).first
  end

  def attributes_to_copy
    personal_details_fields + professional_status_fields + employment_history_fields + ask_for_support_fields
  end

  def completed_steps
    %w[personal_details professional_status employment_history references ask_for_support]
  end

  def copy_qualifications
    recent_job_application.qualifications.each do |qualification|
      new_qualification = qualification.dup
      new_qualification.update(job_application: new_job_application)
    end
  end

  def copy_employments
    recent_job_application.employments.each do |employment|
      new_employment = employment.dup
      new_employment.update(job_application: new_job_application)
    end
  end

  def copy_references
    recent_job_application.references.each do |reference|
      new_reference = reference.dup
      new_reference.update(job_application: new_job_application)
    end
  end
end
