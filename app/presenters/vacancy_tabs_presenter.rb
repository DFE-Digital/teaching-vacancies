class VacancyTabsPresenter
  TABS_DEFINITION = {
    submitted: %w[submitted reviewed],
    unsuccessful: %w[unsuccessful withdrawn],
    shortlisted: %w[shortlisted],
    interviewing: %w[interviewing],
    offered: %w[offered declined],
  }.stringify_keys

  def self.tabs_data(vacancy)
    TABS_DEFINITION.transform_values do |statuses|
      ordering = statuses.map { :"#{it}_at" }.index_with { :desc }
      vacancy.job_applications.where(status: statuses).order(ordering)
    end
  end
end
