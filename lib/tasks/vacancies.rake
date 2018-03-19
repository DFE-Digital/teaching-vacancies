desc 'Scrapes vacancies from jobsinschoolsnorthest.com for'
namespace :vacancies do
  namespace :data do
    task scrape: :environment do
      Rails.logger.debug("Running vacancies scrape task in #{Rails.env}")
      require 'vacancy_scraper'
      VacancyScraper::NorthEastSchools::Processor.execute!
    end
  end
end
