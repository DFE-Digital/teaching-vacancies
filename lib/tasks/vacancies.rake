namespace :vacancies do
  namespace :data do
    desc 'Scrapes vacancies from jobsinschoolsnortheast.com'
    task scrape: :environment do
      Rails.logger.debug("Running vacancies scrape task in #{Rails.env}")
      require 'vacancy_scraper'
      VacancyScraper::NorthEastSchools::Processor.execute!
    end

    desc 'Deletes vacancies specified in lib/tasks/vacancies_to_update.yaml'
    task delete: :environment do
      Rails.logger.debug("Deleting scraped vacancies in #{Rails.env}")
      vacancies = YAML.load_file(Rails.root.join('lib', 'tasks', 'vacancies_to_update.yaml'))['vacancies']['delete']
      vacancies.each do |slug|
        Rails.logger.debug("Deleting vacancy #{slug}")
        vacancy = Vacancy.find_by(slug: slug)
        vacancy&.delete
      end
    end

    desc 'Updates vacancies specified in lib/task/vacancies_to_update.yaml'
    task update: :environment do
      Rake::Task['vacancies:data:delete'].execute
      Rails.logger.debug("Editing scraped vacancies in #{Rails.env}")
      vacancies = YAML.load_file(Rails.root.join('lib', 'tasks', 'vacancies_to_update.yaml'))['vacancies']['update']

      vacancies.each do |data|
        Rails.logger.debug("Updating vacancy #{data['slug']}")
        vacancy = Vacancy.find_by(slug: data['slug'])
        next if vacancy.nil? || vacancy.created_at != vacancy.updated_at
        vacancy.job_title = data['job_title']
        vacancy.job_description = data['job_description'] if data.key?('job_description')
        vacancy.experience      = data['experience']      if data.key?('experience')
        vacancy.benefits        = data['benefits']        if data.key?('benefits')
        vacancy.qualifications  = data['qualifications']  if data.key?('qualifications')

        vacancy.subject = Subject.find_by(name: data['subject']) if data.key?('subject')
        if data.key?('leadership_title')
          vacancy.leadership = Leadership.find_by(title: data['leadership_title'])
        end

        vacancy.save(validate: false)
      end
    end
  end
end
