class Publishers::VacancyFormSequence
  def initialize(vacancy:, step_names:)
    @vacancy = vacancy

    @step_names = step_names
    @form_prefix = "publishers/job_listing"
  end

  def validate_all_steps
    validatable_steps.each.with_object({}) { |step_name, hash| hash[step_name] = validate_step(step_name) }
  end

  def all_steps_valid?
    validate_all_steps.values.all?(&:valid?)
  end

  def next_invalid_step
    # Due to subjects being an optional step (no validations) it needs to be handled differently
    return :subjects if next_incomplete_step_subjects?

    validate_all_steps.filter_map { |step, form| step if form.invalid? }.first
  end

  private

  def validatable_steps
    @step_names - not_validatable_steps
  end

  def validate_step(step_name)
    step_form_class = File.join(@form_prefix, "#{step_name}_form").camelize.constantize

    step_form_class.load_from_model(@vacancy, current_publisher: nil).tap do |form|
      form.valid?
      @vacancy.errors.merge!(
        form.errors.tap do |errors|
          errors.each { |e| e.options[:step] = step_name }
        end,
      )
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

  def not_validatable_steps
    %i[subjects review].freeze
  end
end
