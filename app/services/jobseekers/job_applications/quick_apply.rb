class Jobseekers::JobApplications::QuickApply
  attr_reader :jobseeker, :vacancy

  def initialize(jobseeker, vacancy)
    @jobseeker = jobseeker
    @vacancy = vacancy
  end

  def job_application
    return new_job_application unless previously_submitted_application? || jobseeker_profile

    source = previously_submitted_application? ? recent_job_application : jobseeker_profile
    copy_personal_info(source)
    copy_qualifications(source)
    copy_employments(source)
    copy_references(source)
    copy_training_and_cpds(source)
    set_status_of_each_step(source)
    new_job_application.save
    new_job_application
  end

  private

  def copy_personal_info(source)
    if source.is_a? JobApplication
      new_job_application.assign_attributes(recent_job_application.slice(*attributes_to_copy))
    elsif source.is_a? JobseekerProfile
      new_job_application.assign_attributes(
        first_name: jobseeker_profile.personal_details&.first_name,
        last_name: jobseeker_profile.personal_details&.last_name,
        phone_number: jobseeker_profile.personal_details&.phone_number,
        qualified_teacher_status_year: jobseeker_profile.qualified_teacher_status_year || "",
        qualified_teacher_status: jobseeker_profile.qualified_teacher_status || "",
        right_to_work_in_uk: jobseeker_right_to_work,
      )
    end
  end

  def jobseeker_right_to_work
    return "" if jobseeker_profile.personal_details&.right_to_work_in_uk.nil?

    jobseeker_profile.personal_details.right_to_work_in_uk? ? "yes" : "no"
  end

  def set_status_of_each_step(source)
    if source.is_a? JobApplication
      set_step_statuses_for_import_from_job_application
    elsif source.is_a? JobseekerProfile
      set_step_statuses_for_import_from_jobseeker_profile
    end
  end

  def set_step_statuses_for_import_from_job_application
    new_job_application.completed_steps = completed_steps
    new_job_application.imported_steps = completed_steps
    new_job_application.in_progress_steps = []
  end

  # rubocop:disable Metrics/AbcSize
  def set_step_statuses_for_import_from_jobseeker_profile
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

  def relevant_steps
    # The step process is needed in order to filter out the steps that are not relevant to the new job application,
    # for eg. professional status - see https://github.com/DFE-Digital/teaching-vacancies/blob/75cec792d9e229fb866bdafc017f82501bd01001/app/services/jobseekers/job_applications/job_application_step_process.rb#L23
    # The review step is used as a current step is required.
    Jobseekers::JobApplications::JobApplicationStepProcess.new(:review, job_application: new_job_application).steps
  end

  def new_job_application
    @new_job_application ||= jobseeker.job_applications.create(vacancy: vacancy)
  end

  def recent_job_application
    @recent_job_application ||= jobseeker.job_applications.not_draft.order(submitted_at: :desc).first
  end

  def attributes_to_copy
    %i[personal_details professional_status ask_for_support personal_statement].select { |step| relevant_steps.include?(step) }
                                                                               .map { |step| form_fields_from_step(step) }
                                                                               .flatten
  end

  def form_fields_from_step(step)
    "jobseekers/job_application/#{step}_form".camelize.constantize.fields
  end

  def completed_steps
    %w[personal_details professional_status personal_statement references ask_for_support qualifications employment_history training_and_cpds].select { |step| relevant_steps.include?(step.to_sym) }
  end

  def in_progress_steps
    %w[]
  end

  def copy_qualifications(source)
    source.qualifications.each do |qualification|
      new_qualification = qualification.dup
      new_qualification.update(job_application: new_job_application)

      qualification.qualification_results.each do |result|
        new_result = result.dup
        new_result.update(qualification: new_qualification)
      end
    end

    qualifications_section_completed = true if source.is_a? JobApplication
    qualifications_section_completed = false if source.is_a? JobseekerProfile

    new_job_application.qualifications_section_completed = qualifications_section_completed
  end

  def copy_employments(source)
    source.employments.each do |employment|
      new_employment = employment.dup
      new_employment.update(job_application: new_job_application, salary: "")
    end

    employment_section_completed = true if source.is_a? JobApplication
    employment_section_completed = false if source.is_a? JobseekerProfile

    new_job_application.employment_history_section_completed = employment_section_completed
  end

  def copy_references(source)
    return unless source.is_a? JobApplication

    source.references.each do |reference|
      new_reference = reference.dup
      new_reference.update(job_application: new_job_application)
    end
  end

  def copy_training_and_cpds(source)
    source.training_and_cpds.each do |training|
      new_training = training.dup
      new_training.update(job_application: new_job_application)
    end

    training_section_completed = true if source.is_a? JobApplication
    training_section_completed = false if source.is_a? JobseekerProfile

    new_job_application.training_and_cpds_section_completed = training_section_completed
  end

  def previously_submitted_application?
    jobseeker.job_applications.not_draft.any?
  end

  def jobseeker_profile
    @jobseeker_profile ||= jobseeker.jobseeker_profile
  end
end
