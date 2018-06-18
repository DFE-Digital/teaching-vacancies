namespace :elasticsearch do
  desc 'Index vacancies'
  namespace :vacancies do
    task index: :environment do
      Rails.logger.debug("Re-index job listings in #{Rails.env}")
      Vacancy.import(force: true)
    end
  end
end
