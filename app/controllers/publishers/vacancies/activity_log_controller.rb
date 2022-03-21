class Publishers::Vacancies::ActivityLogController < Publishers::Vacancies::BaseController
  def show
    @versions = vacancy.versions.reorder(created_at: :desc)
  end
end
