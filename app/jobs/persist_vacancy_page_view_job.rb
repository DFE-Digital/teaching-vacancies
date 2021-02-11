class PersistVacancyPageViewJob < ActiveJob::Base
  queue_as :low

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    vacancy.increment!(:total_pageviews)
  end
end
