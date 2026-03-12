namespace :db do
  desc "Asynchronously import organisations from GIAS and seed the database"
  task async_seed: :environment do
    SeedDatabaseJob.perform_later
  end

  desc "Generates 1000 random vacancies for testing purposes"
  task create_random_vacancies: :environment do
    1000.times do
      school = School.not_closed.order(Arel.sql("RANDOM()")).first
      FactoryBot.create(:vacancy, :for_seed_data, organisations: [school])
    end
  end

  desc "Add FriendlyId slugs to Organisation records"
  task add_friendlyid_organisation_slugs: :environment do
    SetOrganisationSlugsJob.perform_now
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
    SetOrganisationSlugsJob.perform_now
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
    OnsDataImport::ImportCounties.call
  end

  desc "Import ONS cities"
  task import_cities: :environment do
    OnsDataImport::ImportCities.call
  end

  desc "Import ONS regions"
  task import_regions: :environment do
    OnsDataImport::ImportRegions.call
  end

  desc "Create composites from ONS polygons"
  task create_composites: :environment do
    OnsDataImport::CreateComposites.new.call
  end
end

namespace :backfills do
  desc "Backfill vacancy geolocation"
  task vacancy_geolocation: :environment do
    Vacancy.backfill_missing_geolocations
  end

  desc "Backfill vacancy searchable content"
  task vacancy_searchable_content: :environment do
    Vacancy.backfill_missing_searchable_content
  end
end

namespace :job_preferences do
  desc "Migrate legacy working patterns"
  task migrate_legacy_working_patterns: :environment do
    JobPreferences.migrate_legacy_working_patterns
  end
end

namespace :subscriptions do
  desc "Discard subscriptions that fail validation (probably due to invalid email address)"
  task discard_invalid: :environment do
    Subscription.discard_invalid
  end
end

namespace :vacancies do
  desc "Trash published vacancies from out-of-scope schools"
  task discard_out_of_scope: :environment do
    PublishedVacancy.discard_out_of_scope
  end
end

namespace :publishers do
  desc "Reset 'New features' attributes so all publishers are shown 'New features' page"
  task reset_new_features_attributes: :environment do
    Publisher.update_all(dismissed_new_features_page_at: nil)
  end

  desc "Reset accepted terms for all publishers"
  task reset_accepted_terms_at: :environment do
    Publisher.update_all(accepted_terms_at: nil)
  end
end
