class Publishers::VacancyFormSequence < FormSequence
  def initialize(vacancy:, organisation:, step_process:)
    @vacancy = vacancy
    @step_process = step_process

    super(
      model: @vacancy,
      organisation: organisation,
      step_names: @step_process.steps,
      form_prefix: "publishers/job_listing",
    )
  end

  def next_invalid_step
    # Due to subjects being an optional step (no validations) it needs to be handled differently
    return :subjects if next_incomplete_step_subjects?
    return :confirm_contact_details if next_incomplete_step_confirm_contact_details?

    validate_all_steps.filter_map { |step, form| step if form.invalid? }.first
  end

  private

  def validatable_steps
    if @vacancy.published?
      dependent_steps
    else
      super
    end
  end

  def dependent_steps # rubocop:disable Metrics/MethodLength
    case @step_process.current_step
    when :job_location
      %i[education_phases key_stages]
    when :job_role
      %i[key_stages about_the_role]
    when :education_phases
      %i[key_stages]
    when :key_stages
      %i[about_the_role]
    when :applying_for_the_job
      %i[how_to_receive_applications] unless @vacancy.enable_job_applications
    when :how_to_receive_applications
      if @vacancy.uploaded_form?
        %i[application_form]
      else
        %i[application_link]
      end
    when :include_additional_documents
      %i[documents]
    else
      []
    end
  end

  def next_incomplete_step_subjects?
    return false unless @vacancy.allow_subjects?
    return false if @vacancy.completed_steps.include?("subjects")

    @vacancy.completed_steps.last == if @vacancy.allow_key_stages?
                                       "key_stages"
                                     else
                                       "job_role"
                                     end
  end

  def next_incomplete_step_confirm_contact_details?
    return false if @vacancy.contact_email_belongs_to_a_publisher?

    @vacancy.completed_steps.last == "contact_details"
  end

  def not_validatable_steps
    %i[subjects review confirm_contact_details].freeze
  end
end
