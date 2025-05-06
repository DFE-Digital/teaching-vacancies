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

  def vacancy_draft_status(organisation, vacancy, section)
    step_process = Publishers::Vacancies::VacancyStepProcess.new(:review, organisation: organisation, vacancy: vacancy)

    active_steps = step_process.step_groups[section]
    completed_steps = vacancy.completed_steps.map(&:to_sym).intersection(active_steps)
    if active_steps - completed_steps == []
      { status: :completed, colour: "blue" }
    elsif completed_steps.any?
      { status: :in_progress, colour: "green" }
    end
  end

  private

  def complete
    { text: t("shared.status_tags.complete") }
  end

  def incomplete
    govuk_tag(text: t("shared.status_tags.incomplete"), colour: "yellow")
  end

  def imported
    govuk_tag(text: t("shared.status_tags.imported"), colour: "blue")
  end
end
