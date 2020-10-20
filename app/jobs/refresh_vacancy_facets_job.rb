class RefreshVacancyFacetsJob < ApplicationJob
  queue_as :refresh_vacancy_facets

  def perform
    VacancyFacets.new.refresh
  end
end
