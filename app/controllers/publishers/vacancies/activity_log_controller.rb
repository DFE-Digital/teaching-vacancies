class Publishers::Vacancies::ActivityLogController < Publishers::Vacancies::BaseController
  before_action :set_vacancy

  def show
    @versions = vacancy.versions.reorder(created_at: :desc)
  end
end
