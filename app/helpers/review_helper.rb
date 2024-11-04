module ReviewHelper
  def section_begun?(model, section, step_process)
    # fields = retrieve_section_forms(section, step_process).then { retrieve_fields_from_forms(_1) }
    form_classes = retrieve_section_forms(section, step_process)

    fields = form_classes.map { |form_class| form_class.load_form(model) }.map(&:values).flatten

    # form_models.map(&:fields).flatten

    # model.slice(fields).values.any? { |value| !value.nil? }
    fields.any? { |value| !value.nil? }
  end

  private

  def retrieve_section_forms(section, step_process)
    step_process.step_groups[section].map do |step_name|
      File.join("publishers/job_listing", "#{step_name}_form").camelize.constantize
    end
  end
end
