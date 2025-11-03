class Publishers::Vacancies::WizardController < Publishers::Vacancies::BuildController
  def redirect_to_next_step
    if save_and_finish_later?
      redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success")
    elsif next_step.to_sym == :wicked_finish
      redirect_to_next nil, success: t("publishers.vacancies.show.success")
    else
      redirect_to_next step_process.next_step
    end
  end

  def finish_wizard_path
    organisation_job_review_path(vacancy.id)
  end
end
