module StatusTagHelper
  def review_section_tag(resource, form_classes)
    steps = form_classes.map(&:target_name)
    if resource.is_a?(JobApplication) && steps.all? { |step| job_application_step_imported?(resource, step) }
      imported
    elsif form_classes.all?(&:optional?)
      optional
    elsif resource.is_a?(JobApplication) && steps.all? { |step| job_application_step_in_progress?(resource, step) }
      in_progress
    elsif steps.none? { |step| step_completed?(resource, step) }
      not_started
    elsif step_forms_contain_errors?(resource, form_classes)
      action_required
    else
      complete
    end
  end

  private

  def step_completed?(resource, step)
    resource.completed_steps.include?(step.to_s)
  end

  def step_forms_contain_errors?(resource, form_classes)
    form_classes.any? do |form_class|
      form_class.fields.any? { |field| resource.errors.include?(field) }
    end
  end

  def optional
    govuk_tag(text: t("shared.status_tags.optional"), colour: "grey")
  end

  def not_started
    govuk_tag(text: t("shared.status_tags.not_started"), colour: "grey")
  end

  def action_required
    govuk_tag(text: t("shared.status_tags.action_required"), colour: "red")
  end

  def complete
    govuk_tag(text: t("shared.status_tags.complete"), colour: "green")
  end

  def in_progress
    govuk_tag(text: t("shared.status_tags.in_progress"), colour: "yellow")
  end

  def imported
    govuk_tag(text: t("shared.status_tags.imported"), colour: "blue")
  end
end
