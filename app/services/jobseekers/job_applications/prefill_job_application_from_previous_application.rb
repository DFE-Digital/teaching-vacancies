class Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication
  def initialize(jobseeker, new_job_application)
    @jobseeker = jobseeker
    @new_job_application = new_job_application
  end

  def call
    copy_personal_info
    copy_associations(recent_job_application.qualifications)
    copy_associations(recent_job_application.employments)
    copy_associations(recent_job_application.training_and_cpds)
    copy_associations(recent_job_application.professional_body_memberships)
    copy_associations(recent_job_application.referees)
    set_status_of_each_step
    new_job_application.save
    new_job_application
  end

  PLAIN_STEPS = %w[personal_details referees ask_for_support qualifications training_and_cpds professional_body_memberships following_religion religion_details].freeze

  private

  attr_reader :jobseeker, :new_job_application

  # rubocop:disable Metrics/AbcSize
  def copy_personal_info
    attributes = attributes_to_copy
    if attributes.include? :baptism_certificate
      new_job_application.assign_attributes(recent_job_application.slice(*(attributes - [:baptism_certificate])))
      new_job_application.update(content: recent_job_application.content.body)

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
      new_job_application.update(content: recent_job_application.content.body)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def attributes_to_copy
    (relevant_steps - %i[review declarations equal_opportunities personal_statement])
      .flat_map { |step| form_fields_from_step(step) }
  end

  def copy_associations(associations)
    associations.map(&:duplicate).each do |new_record|
      new_record.assign_attributes(job_application: new_job_application)
      new_record.save(validate: false)
    end
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
    Jobseekers::JobApplications::JobApplicationStepProcess.new(job_application: new_job_application).steps
  end

  def completed_steps
    completed_steps = PLAIN_STEPS.select { |step| relevant_steps.include?(step.to_sym) }
    completed_steps << "employment_history" unless previous_application_was_submitted_before_we_began_validating_gaps_in_work_history? || recent_job_application.employments.reject(&:valid?).any?
    completed_steps << "professional_status" if previous_application_has_professional_status_details?
    completed_steps
  end

  def in_progress_steps
    steps = %w[personal_statement]
    steps << "employment_history" if previous_application_was_submitted_before_we_began_validating_gaps_in_work_history?
    steps << "professional_status" unless previous_application_has_professional_status_details?
    steps
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
