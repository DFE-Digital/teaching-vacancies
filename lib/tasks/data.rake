namespace :data do
  desc "Import school data"
  namespace :schools do
    task import: :environment do
      Rails.logger.debug("Running school import task in #{Rails.env}")
      ImportSchoolDataJob.perform_later
    end
  end

  desc "Import school group data"
  namespace :school_groups do
    task import: :environment do
      Rails.logger.debug("Running school group import task in #{Rails.env}")
      ImportTrustDataJob.perform_later
    end
  end

  desc "Import location polygons"
  namespace :location_polygons do
    task import_regions: :environment do
      Rails.logger.debug("Running region location polygon import task in #{Rails.env}")
      ImportPolygons.new(location_type: :regions).call
    end

    task import_counties: :environment do
      Rails.logger.debug("Running counties location polygon import task in #{Rails.env}")
      ImportPolygons.new(location_type: :counties).call
    end

    task import_london_boroughs: :environment do
      Rails.logger.debug("Running london boroughs location polygon import task in #{Rails.env}")
      ImportPolygons.new(location_type: :london_boroughs).call
    end

    task import_cities: :environment do
      Rails.logger.debug("Running cities location polygon import task in #{Rails.env}")
      ImportPolygons.new(location_type: :cities).call
    end
  end

  desc "Update DfE Sign In users data"
  namespace :users do
    task update: :environment do
      Rails.logger.debug("Running DfE Sign In users update task in #{Rails.env}")
      UpdateDsiUsersInDbJob.perform_later
    end
  end

  desc "Remove Algolia indices"
  namespace :indices do
    task remove: :environment do
      Rails.logger.debug("Removing indices in #{Rails.env}")
      replicas = Vacancy.index.get_settings["replicas"]
      Vacancy.index.set_settings({ replicas: [] })
      Algolia.client.delete_index(Vacancy::INDEX_NAME)
      replicas.each { |replica| Algolia.client.delete_index(replica) }
    end
  end
end
