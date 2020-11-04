namespace :vacancies do
  namespace :statistics do
    desc "Refreshes the cached pageviews for listed non expired job vacancies"
    task refresh_cache: :environment do
      Vacancy.listed.applicable.pluck(:id).each do |vacancy_id|
        PersistVacancyPageViewJob.perform_later(vacancy_id)
        PersistVacancyGetMoreInfoClickJob.perform_later(vacancy_id)
      end
    end
  end
end
