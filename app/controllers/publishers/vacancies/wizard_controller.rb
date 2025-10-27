class Publishers::Vacancies::WizardController < Publishers::Vacancies::BuildController
  def redirect_to_next_step
    if save_and_finish_later?
      redirect_to organisation_job_path(vacancy.id), success: t("publishers.vacancies.show.success") and return
    end

    if step.name == "contact_details" && !vacancy.contact_email_belongs_to_a_publisher?
      # we don't validate confirm_contact_details step in all_steps_valid? which means all_steps_valid is true at this point, so we need to manually redirect here
      # to ensure the user sees the confirm contact_details page
      redirect_to organisation_job_wizard_path(vacancy.id, :confirm_contact_details) and return
    end

    if next_step.to_sym == :wicked_finish
      redirect_to_next nil, success: t("publishers.vacancies.show.success")
    else
      redirect_to_next step_process.next_step
    end
  end

  def finish_wizard_path
    organisation_job_review_path(vacancy.id)
  end
end
