class FormSequence
  def initialize(model:, organisation:, step_names:, form_prefix:)
    @model = model
    @organisation = organisation
    @step_names = step_names
    @form_prefix = form_prefix
  end

  def validate_all_steps
    validatable_steps.each.with_object({}) { |step_name, hash| hash[step_name] = validate_step(step_name) }
  end

  def all_steps_valid?
    validate_all_steps.values.all?(&:valid?)
  end

  private

  def validatable_steps
    @step_names - not_validatable_steps
  end

  def not_validatable_steps
    []
  end

  def validate_step(step_name)
    step_form_class = File.join(@form_prefix, "#{step_name}_form").camelize.constantize

    params = step_form_class.load_form(@model)
      .merge(current_organisation: @organisation)

    step_form_class.new(params, @model).tap do |form|
      form.valid?
      @model.errors.merge!(
        form.errors.tap do |errors|
          errors.each { |e| e.options[:step] = step_name }
        end,
      )
    end
  end
end
