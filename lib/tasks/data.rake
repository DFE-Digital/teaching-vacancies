namespace :data do
  desc 'Import school data'
  namespace :schools do
    task import: :environment do
      Rails.logger.debug("Running school import task in #{Rails.env}")
      UpdateSchoolsDataFromSourceJob.perform_later
    end
  end

  desc 'Import school group data'
  namespace :school_groups do
    task import: :environment do
      Rails.logger.debug("Running school group import task in #{Rails.env}")
      ImportSchoolGroupDataJob.perform_later
    end
  end

  desc 'Export location category data'
  namespace :location_categories do
    task export: :environment do
      Rails.logger.debug("Running location category export task in #{Rails.env}")
      LocationCategory.export
    end
  end

  desc 'Update DfE Sign In users data'
  namespace :users do
    task update: :environment do
      Rails.logger.debug("Running DfE Sign In users update task in #{Rails.env}")
      UpdateDfeSignInUsersJob.perform_later
    end
  end
end
