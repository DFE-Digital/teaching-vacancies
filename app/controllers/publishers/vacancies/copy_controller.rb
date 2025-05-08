class Publishers::Vacancies::CopyController < Publishers::Vacancies::BaseController
  include Publishers::VacancyCopy
  def create
    new_vacancy = copy_vacancy(vacancy)

    redirect_to organisation_job_path(new_vacancy.id), success: t("publishers.vacancies.show.copied.success")
  end
end
