namespace :data do
  desc 'Import school data'
  namespace :schools do
    task import: :environment do
      Rails.logger.debug("Running school import task in #{Rails.env}")
      UpdateSchoolsDataFromSourceJob.perform_later
    end
  end

  desc 'Export location category data'
  namespace :location_categories do
    task export: :environment do
      Rails.logger.debug("Running location category export task in #{Rails.env}")
      LocationCategory.export
    end
  end
end
