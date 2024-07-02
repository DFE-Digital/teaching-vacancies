class Jobseekers::JobApplications::PrefillJobApplicationFromJobseekerProfile
  attr_reader :jobseeker, :vacancy, :new_job_application

  def initialize(jobseeker, vacancy, new_job_application)
    @jobseeker = jobseeker
    @vacancy = vacancy
    @new_job_application = new_job_application
  end

  def call
    copy_personal_info
    copy_qualifications
    copy_employments
    copy_training_and_cpds
    set_status_of_each_step
    new_job_application.save
    new_job_application
  end

  def copy_personal_info
    new_job_application.assign_attributes(
      first_name: jobseeker_profile.personal_details&.first_name,
      last_name: jobseeker_profile.personal_details&.last_name,
      phone_number: jobseeker_profile.personal_details&.phone_number,
      qualified_teacher_status_year: jobseeker_profile.qualified_teacher_status_year || "",
      qualified_teacher_status: jobseeker_profile.qualified_teacher_status || "",
      right_to_work_in_uk: jobseeker_right_to_work,
    )
  end

  def copy_qualifications
    jobseeker_profile.qualifications.each do |qualification|
      new_qualification = qualification.dup
      new_qualification.update(job_application: new_job_application)

      qualification.qualification_results.each do |result|
        new_result = result.dup
        new_result.update(qualification: new_qualification)
      end
    end

    new_job_application.qualifications_section_completed = false
  end

  def copy_employments
    jobseeker_profile.employments.each do |employment|
      new_employment = employment.dup
      new_employment.update(job_application: new_job_application, salary: "")
    end

    new_job_application.employment_history_section_completed = false
  end

  def copy_training_and_cpds
    jobseeker_profile.training_and_cpds.each do |training|
      new_training = training.dup
      new_training.update(job_application: new_job_application)
    end

    new_job_application.training_and_cpds_section_completed = false
  end

  # rubocop:disable Metrics/AbcSize
  def set_status_of_each_step
    new_job_application.completed_steps = []
    new_job_application.imported_steps = []

    if new_job_application.first_name.present? || new_job_application.last_name.present? || new_job_application.phone_number.present? || new_job_application.right_to_work_in_uk.present?
      new_job_application.in_progress_steps += [:personal_details]
    end

    new_job_application.in_progress_steps += [:employment_history] if new_job_application.employments.any?
    new_job_application.in_progress_steps += [:professional_status] if new_job_application.qualified_teacher_status.present?
    new_job_application.in_progress_steps += [:training_and_cpds] if new_job_application.training_and_cpds.any?
    new_job_application.in_progress_steps += [:qualifications] if new_job_application.qualifications.present?
  end
  # rubocop:enable Metrics/AbcSize

  def jobseeker_right_to_work
    return "" if jobseeker_profile.personal_details&.right_to_work_in_uk.nil?

    jobseeker_profile.personal_details.right_to_work_in_uk? ? "yes" : "no"
  end

  def jobseeker_profile
    @jobseeker_profile ||= jobseeker.jobseeker_profile
  end
end
