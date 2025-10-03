class Publishers::Vacancies::ActivityLogController < Publishers::Vacancies::WizardBaseController
  def show
    @versions = vacancy.versions.reorder(created_at: :desc)
  end
end
