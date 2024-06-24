class Jobseekers::JobApplications::QuickApply
  attr_reader :jobseeker, :vacancy

  def initialize(jobseeker, vacancy)
    @jobseeker = jobseeker
    @vacancy = vacancy
  end

  def job_application
    new_job_application.assign_attributes(recent_job_application.slice(*attributes_to_copy))
    set_status_of_each_step
    copy_qualifications
    copy_employments
    copy_references
    copy_training_and_cpds
    new_job_application.save
    new_job_application
  end

  private

  def set_status_of_each_step
    new_job_application.completed_steps = completed_steps
    new_job_application.imported_steps = completed_steps
    new_job_application.in_progress_steps = []
  end

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
    new_job_application.employment_history_section_completed = true
  end

  def copy_references
    recent_job_application.references.each do |reference|
      new_reference = reference.dup
      new_reference.update(job_application: new_job_application)
    end
  end

  def copy_training_and_cpds
    return if recent_job_application.training_and_cpds.empty?

    recent_job_application.training_and_cpds.each do |training|
      new_training = training.dup
      new_training.update(job_application: new_job_application)
    end

    new_job_application.training_and_cpds_section_completed = true
  end
end
