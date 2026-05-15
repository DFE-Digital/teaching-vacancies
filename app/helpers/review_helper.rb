module ReviewHelper
  def section_begun?(model, section, step_process)
    retrieve_section_forms(section, step_process)
      .map { |form_class| form_class.load_from_model(model, current_publisher: nil).slice(*form_class.fields).values }
      .flatten
      .any? { |value| !value.nil? }
  end

  private

  def retrieve_section_forms(section, step_process)
    step_process.steps_list_for(section).map do |step_name|
      File.join("publishers/job_listing", "#{step_name}_form").camelize.constantize
    end
  end
end
