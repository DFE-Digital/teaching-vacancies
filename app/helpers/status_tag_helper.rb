module StatusTagHelper
  def review_section_tag(resource, steps, form_classes)
    return if (resource.is_a?(Vacancy) || resource.is_a?(VacancyPresenter)) && resource.published?

    if form_classes.all?(&:optional?)
      optional
    elsif steps.none? { |step| vacancy_step_completed?(resource, step) }
      not_started
    elsif step_forms_contain_errors?(resource, form_classes)
      action_required
    else
      complete
    end
  end

  private

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
    govuk_tag(text: t("shared.status_tags.complete"))
  end
end
