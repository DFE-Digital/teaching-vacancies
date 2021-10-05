module StatusTagHelper
  def review_section_tag(resource, steps, form_classes)
    return govuk_tag(text: t("shared.status_tags.not_started"), colour: "grey") if steps.none? { |step| vacancy_step_completed?(resource, step) }

    return govuk_tag(text: t("shared.status_tags.action_required"), colour: "red") if step_forms_contain_errors?(resource, form_classes)

    govuk_tag text: t("shared.status_tags.complete")
  end

  private

  def step_forms_contain_errors?(resource, form_classes)
    form_classes.each do |form_class|
      return true if form_class.fields.any? { |field| field.in?(resource.errors.messages.keys) }
    end

    false
  end
end
