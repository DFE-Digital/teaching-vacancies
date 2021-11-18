class FormSequence
  NOT_VALIDATABLE = %i[documents review].freeze

  def initialize(model:, organisation:, step_names:, form_prefix:)
    @model = model
    @organisation = organisation
    @step_names = step_names
    @form_prefix = form_prefix
  end

  def validate_all_steps
    validatable_steps.each.with_object({}) { |s, h| h[s] = validate_step(s) }
  end

  def all_steps_valid?
    validate_all_steps.values.all?(&:valid?)
  end

  def validatable_steps
    @step_names - NOT_VALIDATABLE
  end

  private

  def validate_step(step_name)
    step_form = File.join(@form_prefix, "#{step_name}_form").camelize.constantize

    params = @model
      .slice(*step_form.fields)
      .merge(current_organisation: @organisation)

    step_form.new(params, @model).tap do |form|
      form.valid?
      @model.errors.merge!(
        form.errors.tap do |errors|
          errors.each { |e| e.options[:step] = step_name }
        end,
      )
    end
  end
end
