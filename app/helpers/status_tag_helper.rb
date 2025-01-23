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
  def review_section_tag(resource, step)
    if step_completed?(resource, step)
      complete
    elsif resource.imported_steps.include?(step.to_s)
      imported
    else
      incomplete
    end
  end
  # rubocop:enable Lint/DuplicateBranch

  private

  def step_completed?(resource, step)
    resource.completed_steps.include?(step.to_s)
  end

  def complete
    govuk_tag(text: t("shared.status_tags.complete"), colour: "green")
  end

  def incomplete
    govuk_tag(text: t("shared.status_tags.incomplete"), colour: "yellow")
  end

  def imported
    govuk_tag(text: t("shared.status_tags.imported"), colour: "blue")
  end
end
