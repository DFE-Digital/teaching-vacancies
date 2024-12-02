class Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication
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
    copy_references
    copy_training_and_cpds
    set_status_of_each_step
    new_job_application.save
    new_job_application
  end

  private

  def copy_personal_info
    attributes = attributes_to_copy
    if attributes.include? :baptism_certificate
      new_job_application.assign_attributes(recent_job_application.slice(*(attributes - [:baptism_certificate])))

      if recent_job_application.baptism_certificate.present?
        recent_job_application.baptism_certificate.blob.open do |tempfile|
          new_job_application.baptism_certificate.attach({
            io: tempfile,
            filename: recent_job_application.baptism_certificate.blob.filename,
            content_type: recent_job_application.baptism_certificate.blob.content_type,
          })
        end
      end
    else
      new_job_application.assign_attributes(recent_job_application.slice(*attributes))
    end
  end

  def attributes_to_copy
    %i[personal_details
       professional_status
       ask_for_support
       personal_statement
       following_religion
       catholic_religion_details
       school_ethos
       non_catholic_religion_details]
      .select { |step| relevant_steps.include?(step) }
      .map { |step| form_fields_from_step(step) }
      .flatten - jobseeker_profile_fields
  end

  def jobseeker_profile_fields
    %i[has_teacher_reference_number teacher_reference_number]
  end

  def copy_qualifications
    recent_job_application.qualifications.each do |qualification|
      new_qualification = qualification.dup
      new_qualification.update(job_application: new_job_application)

      qualification.qualification_results.each do |result|
        new_result = result.dup
        new_result.update(qualification: new_qualification)
      end
    end

    new_job_application.qualifications_section_completed = true
  end

  def copy_employments
    recent_job_application.employments.each do |employment|
      new_employment = employment.dup
      new_employment.update(job_application: new_job_application, salary: "")
    end

    new_job_application.employment_history_section_completed = !previous_application_was_submitted_before_we_began_validating_gaps_in_work_history?
  end

  def copy_references
    recent_job_application.references.each do |reference|
      new_reference = reference.dup
      new_reference.update(job_application: new_job_application)
    end
  end

  def copy_training_and_cpds
    recent_job_application.training_and_cpds.each do |training|
      new_training = training.dup
      new_training.update(job_application: new_job_application)
    end

    new_job_application.training_and_cpds_section_completed = true
  end

  def set_status_of_each_step
    new_job_application.completed_steps = completed_steps
    new_job_application.imported_steps = completed_steps
    new_job_application.in_progress_steps = in_progress_steps
  end

  def recent_job_application
    @recent_job_application ||= jobseeker.job_applications.not_draft.order(submitted_at: :desc).first
  end

  def relevant_steps
    # The step process is needed in order to filter out the steps that are not relevant to the new job application,
    # for eg. professional status - see https://github.com/DFE-Digital/teaching-vacancies/blob/75cec792d9e229fb866bdafc017f82501bd01001/app/services/jobseekers/job_applications/job_application_step_process.rb#L23
    # The review step is used as a current step is required.
    step_process = Jobseekers::JobApplications::JobApplicationStepProcess.new(:review, job_application: new_job_application)
    step_process.steps
  end

  def completed_steps
    completed_steps = %w[personal_details personal_statement references ask_for_support qualifications training_and_cpds following_religion religion_details].select { |step| relevant_steps.include?(step.to_sym) }
    completed_steps << "employment_history" unless previous_application_was_submitted_before_we_began_validating_gaps_in_work_history?
    completed_steps << "professional_status" if previous_application_has_professional_status_details?
    completed_steps
  end

  def in_progress_steps
    if previous_application_was_submitted_before_we_began_validating_gaps_in_work_history?
      %w[employment_history]
    elsif !previous_application_has_professional_status_details?
      %w[professional_status]
    else
      []
    end
  end

  def form_fields_from_step(step)
    "jobseekers/job_application/#{step}_form".camelize.constantize.storable_fields
  end

  def previous_application_was_submitted_before_we_began_validating_gaps_in_work_history?
    recent_job_application.submitted_at < DateTime.strptime("Apr 3 10:34:11 2024 +0100", "%b %d %H:%M:%S %Y %z")
  end

  def previous_application_has_professional_status_details?
    recent_job_application.for_a_teaching_role?
  end
end
