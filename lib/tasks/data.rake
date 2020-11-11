namespace :data do
  namespace :schools do
    desc "Import school data"
    task import: :environment do
      Rails.logger.debug("Running school import task in #{Rails.env}")
      ImportSchoolDataJob.perform_later
    end
  end

  namespace :school_groups do
    desc "Import school group data"
    task import: :environment do
      Rails.logger.debug("Running school group import task in #{Rails.env}")
      ImportTrustDataJob.perform_later
    end
  end

  desc "Import location polygons"
  namespace :location_polygons do
    desc "Import regions location polygons"
    task import_regions: :environment do
      Rails.logger.debug("Running region location polygon import task in #{Rails.env}")
      ImportPolygons.new(location_type: :regions).call
    end

    desc "Import counties location polygons"
    task import_counties: :environment do
      Rails.logger.debug("Running counties location polygon import task in #{Rails.env}")
      ImportPolygons.new(location_type: :counties).call
    end

    desc "Import boroughs location polygons"
    task import_london_boroughs: :environment do
      Rails.logger.debug("Running london boroughs location polygon import task in #{Rails.env}")
      ImportPolygons.new(location_type: :london_boroughs).call
    end

    desc "Import cities location polygons"
    task import_cities: :environment do
      Rails.logger.debug("Running cities location polygon import task in #{Rails.env}")
      ImportPolygons.new(location_type: :cities).call
    end
  end

  namespace :users do
    desc "Update DfE Sign In users data"
    task update: :environment do
      Rails.logger.debug("Running DfE Sign In users update task in #{Rails.env}")
      UpdateDsiUsersInDbJob.perform_later
    end
  end

  namespace :indices do
    desc "Remove Algolia indices"
    task remove: :environment do
      Rails.logger.debug("Removing indices in #{Rails.env}")
      replicas = Vacancy.index.get_settings["replicas"]
      Vacancy.index.set_settings({ replicas: [] })
      Algolia.client.delete_index(Indexable::INDEX_NAME)
      sleep(5) # Needed otherwise replicas are still bound to the primary
      replicas.each { |replica| Algolia.client.delete_index(replica) }
    end
  end
end
