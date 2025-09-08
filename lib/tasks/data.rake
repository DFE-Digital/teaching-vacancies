namespace :db do
  desc "Asynchronously import organisations from GIAS and seed the database"
  task async_seed: :environment do
    SeedDatabaseJob.perform_later
  end

  desc "Reset markers"
  task reset_markers: :environment do
    PublishedVacancy.applicable.find_each(&:reset_markers)
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

namespace :publishers do
  desc "Reset 'New features' attributes so all publishers are shown 'New features' page"
  task reset_new_features_attributes: :environment do
    Publisher.update_all(dismissed_new_features_page_at: nil)
  end
end

# :nocov:
namespace :pre_interviewing_requests do
  desc "Set common pre interviewing request status to self disclosure request and reference request"
  task set_statuses: :environment do
    # from :status, { manual: 0, manually_completed: 1, sent: 2, received: 3 }
    # to :status, { created: 10, requested: 11, received: 12, completed: 13, declined: 14 }
    SelfDisclosureRequest.where(status: 0).update_all(status: 10)
    SelfDisclosureRequest.where(status: 1).update_all(status: 13)
    SelfDisclosureRequest.where(status: 2).update_all(status: 11)
    SelfDisclosureRequest.where(status: 3).update_all(status: 12)

    # from :status, { created: 0, requested: 1, received: 2 }
    # to :status, { created: 10, requested: 11, received: 12, completed: 13, declined: 14 }
    ReferenceRequest.where(status: 0).update_all(status: 10)
    ReferenceRequest.where(status: 1).update_all(status: 11)
    ReferenceRequest.where(status: 2).update_all(status: 12)
    ReferenceRequest.joins(:job_reference)
      .merge(JobReference.where(complete: true, can_give_reference: true))
      .update_all(status: 13)
    ReferenceRequest.joins(:job_reference)
      .merge(JobReference.where(complete: true, can_give_reference: false))
      .update_all(status: 14)
  end
end
# :nocov:
