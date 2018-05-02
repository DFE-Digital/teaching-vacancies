namespace :elasticsearch do
  desc 'Index vacancies'
  namespace :vacancies do
    task index: :environment do
      Rails.logger.debug("Indexing vacancies in #{Rails.env}")
      Vacancy.__elasticsearch__.client.indices.flush
      Vacancy.import
    end
  end
end
