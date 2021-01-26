class RefreshVacancyFacetsJob < ApplicationJob
  queue_as :low

  def perform
    VacancyFacets.new.refresh
  end
end
