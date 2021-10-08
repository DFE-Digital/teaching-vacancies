namespace :algolia do
  desc "Load an index with live records for the first time"
  task reindex: :environment do
    Vacancy.reindex!
  end

  desc "Remove Algolia primary index and replicas"
  task remove_indices: :environment do
    replicas = Vacancy.index.get_settings["replicas"]
    Vacancy.index.set_settings({ replicas: [] })
    Algolia.client.delete_index(Vacancy::Indexable::INDEX_NAME)
    sleep(5) # Needed otherwise replicas are still bound to the primary
    replicas.each { |replica| Algolia.client.delete_index(replica) }
  end

  desc "Update a live index with newly published records using minimal operations"
  task update_index: :environment do
    Vacancy.update_index!
  end
end

namespace :dsi do
  desc "Update DfE Sign-in users data"
  task update_users: :environment do
    require "update_dsi_users_in_db"
    UpdateDsiUsersInDb.new.run!
  end
end

namespace :gias do
  desc "Import schools, trusts and local authorities data"
  task import_schools: :environment do
    ImportOrganisationDataJob.perform_now
  end
end

namespace :ons do
  desc "Import all ONS areas"
  task import_all: %i[import_counties import_cities import_regions]

  desc "Import ONS counties"
  task import_counties: :environment do
    OnsDataImport::ImportCounties.new.call
  end

  desc "Import ONS cities"
  task import_cities: :environment do
    OnsDataImport::ImportCities.new.call
  end

  desc "Import ONS regions"
  task import_regions: :environment do
    OnsDataImport::ImportRegions.new.call
  end

  # TODO: Legacy task - remove after Algolia migration. Depends on the new task to make them both
  # run.
  desc "Import all location polygons"
  task import_location_polygons: %i[environment import_all] do
    %i[regions counties cities].each { |api_location_type| ImportPolygons.new(api_location_type: api_location_type).call }
  end
end
