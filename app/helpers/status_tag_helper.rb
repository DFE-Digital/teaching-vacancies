module StatusTagHelper
  def review_section_tag(job_application, step)
    if job_application.imported_steps.include?(step.to_s) && job_application.completed_steps.include?(step.to_s)
      imported
    elsif job_application.completed_steps.include?(step.to_s)
      complete
    else
      incomplete
    end
  end

  private

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
