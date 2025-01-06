module StatusTagHelper
  STATUS_COLOURS = {
    optional: "grey",
    not_started: "grey",
    action_required: "red",
    complete: "green",
    in_progress: "yellow",
    imported: "blue",
  }.freeze
  # rubocop:disable Lint/DuplicateBranch
  def review_section_tag(resource, form_classes)
    steps = form_classes.map(&:target_name)
    status = if resource.is_a?(JobApplication) && steps.all? { |step| job_application_step_imported?(resource, step) }
               :imported
             elsif form_classes.all?(&:optional?)
               :optional
             elsif resource.is_a?(JobApplication) && steps.all? { |step| job_application_step_in_progress?(resource, step) }
               :in_progress
             elsif steps.none? { |step| step_completed?(resource, step) }
               :not_started
             elsif step_forms_contain_errors?(resource, form_classes)
               :action_required
             elsif steps.all? { |step| step_completed?(resource, step) }
               :complete
             else
               :in_progress
             end
    govuk_tag(text: t("shared.status_tags.#{status}"), colour: STATUS_COLOURS.fetch(status))
  end
  # rubocop:enable Lint/DuplicateBranch

  private

  def step_completed?(resource, step)
    resource.completed_steps.include?(step.to_s)
  end

  def step_forms_contain_errors?(resource, form_classes)
    form_classes.any? do |form_class|
      form_class.fields.any? { |field| resource.errors.include?(field) }
    end
  end
end
