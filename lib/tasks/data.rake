desc 'Import school data'
namespace :data do
  namespace :schools do
    task import: :environment do
      Rails.logger.debug("Running school import task in #{Rails.env}")
      UpdateSchoolsDataFromSourceJob.new.perform
    end
  end
end
