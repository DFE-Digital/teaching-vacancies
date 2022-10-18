class Publishers::Vacancies::CopyController < Publishers::Vacancies::BaseController
  def create
    vacancy.status = :draft
    new_vacancy = CopyVacancy.new(vacancy).call

    redirect_to organisation_job_path(new_vacancy.id), success: t("publishers.vacancies.show.copied.success")
  end
end
