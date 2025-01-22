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
    if steps.all? { |step| resource.in_progress_steps.include?(step.to_s) } || steps.none? { |step| step_completed?(resource, step) }
      incomplete
    elsif steps.all? { |step| resource.imported_steps.include?(step.to_s) }
      imported
    elsif form_classes.all?(&:optional?)
      optional
    elsif step_forms_contain_errors?(resource, form_classes)
      action_required
    else
      complete
    end
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

  def incomplete
    govuk_tag(text: t("shared.status_tags.in_progress"), colour: "yellow")
  end

  def imported
    govuk_tag(text: t("shared.status_tags.imported"), colour: "blue")
  end
end
