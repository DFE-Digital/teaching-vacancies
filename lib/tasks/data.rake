namespace :db do
  desc "Asynchronously import organisations from GIAS and seed the database"
  task async_seed: :environment do
    SeedDatabaseJob.perform_later
  end

  desc "Generates 1000 random vacancies for testing purposes"
  task create_random_vacancies: :environment do
    1000.times do
      school = School.order(Arel.sql("RANDOM()")).first
      FactoryBot.create(:vacancy, organisations: [school])
    end
  end
end

namespace :dsi do
  desc "Update DfE Sign-in users data"
  task update_users: :environment do
    require "update_dsi_users_in_db"
    UpdateDSIUsersInDb.new.run!
  end
end

namespace :gias do
  desc "Import schools, trusts and local authorities data"
  task import_schools: :environment do
    ImportOrganisationDataJob.perform_now
  end
end

namespace :google do
  desc "Remove expired vacancies from the Google index"
  task remove_expired_vacancies_google_index: :environment do
    RemoveExpiredVacanciesFromGoogleIndexJob.perform_later
  end
end

namespace :ons do
  desc "Import all ONS areas"
  task import_all: %i[import_counties import_cities import_regions create_composites]

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

  desc "Create composites from ONS polygons"
  task create_composites: :environment do
    OnsDataImport::CreateComposites.new.call
  end
end

namespace :publishers do
  desc "Reset 'New features' attributes so all publishers are shown 'New features' page"
  task reset_new_features_attributes: :environment do
    Publisher.update_all(dismissed_new_features_page_at: nil)
  end
end

require_relative "../apply_client"
namespace :candidate_api do
  desc "Fetch candidate info and output as a CSV to the given file"
  task fetch_as_csv: :environment do
    csv = ApplyClient.recruited_candidates_csv(recruitment_cycle_year: ENV.fetch("RECRUITMENT_CYCLE_YEAR").to_i)
    File.write(ENV.fetch("OUTPUT_FILE"), csv)
  end
end
