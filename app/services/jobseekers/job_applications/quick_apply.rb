class Jobseekers::JobApplications::QuickApply
  attr_reader :jobseeker, :vacancy

  def initialize(jobseeker, vacancy)
    @jobseeker = jobseeker
    @vacancy = vacancy
  end

  def job_application
    new_job_application.assign_attributes(recent_job_application.slice(*attributes_to_copy).merge(completed_steps: completed_steps, in_progress_steps: in_progress_steps))
    copy_qualifications
    copy_employments
    copy_references
    new_job_application.save
    new_job_application
  end

  private

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
    %i[personal_details professional_status ask_for_support].select { |step| relevant_steps.include?(step) }
                                                            .map { |step| form_fields_from_step(step) }
                                                            .flatten
  end

  def form_fields_from_step(step)
    "jobseekers/job_application/#{step}_form".camelize.constantize.fields
  end

  def completed_steps
    %w[personal_details professional_status references ask_for_support].select { |step| relevant_steps.include?(step.to_sym) }
  end

  def in_progress_steps
    %w[qualifications employment_history]
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
    new_job_application.qualifications_section_completed = false
  end

  def copy_employments
    recent_job_application.employments.each do |employment|
      new_employment = employment.dup
      new_employment.update(job_application: new_job_application, salary: "")
    end
    new_job_application.employment_history_section_completed = false
  end

  def copy_references
    recent_job_application.references.each do |reference|
      new_reference = reference.dup
      new_reference.update(job_application: new_job_application)
    end
  end
end
