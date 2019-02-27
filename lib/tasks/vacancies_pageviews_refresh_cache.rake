namespace :vacancies do
  desc 'Refreshes the cached pageviews for listed non expired job vacancies'
  namespace :pageviews do
    task refresh_cache: :environment do
      Vacancy.listed.applicable.pluck(:id).each do |vacancy_id|
        PersistVacancyPageViewJob.perform_later(vacancy_id)
      end
    end
  end
end
