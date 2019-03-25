namespace :data do
  desc 'Import school data'
  namespace :schools do
    task import: :environment do
      Rails.logger.debug("Running school import task in #{Rails.env}")
      UpdateSchoolsDataFromSourceJob.perform_later
    end
  end

  desc 'Migrate working pattern to array enum'
  namespace :working_pattern do
    task migrate: :environment do
      Vacancy.where(working_patterns: nil)
             .where.not(working_pattern: nil)
             .each do |vacancy|
        vacancy.working_patterns = [vacancy.working_pattern]
        vacancy.save
      end
    end
  end
end
