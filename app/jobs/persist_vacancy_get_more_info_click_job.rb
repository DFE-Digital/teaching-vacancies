class PersistVacancyGetMoreInfoClickJob < ActiveJob::Base
  queue_as :low

  def perform(vacancy_id)
    vacancy = Vacancy.find(vacancy_id)
    vacancy.increment!(:total_get_more_info_clicks)
  end
end
