namespace :db do # rubocop:disable Metrics/BlockLength
  desc "Set job role and ect_status from old job_roles field"
  task set_new_job_role_and_ect_status: :environment do
    main_job_roles = [0, 1, 4, 5, 6, 7]
    Vacancy.published.find_each do |v|
      v.update_columns job_role: (v.job_roles&.find { |r| r.in? main_job_roles } || 0),
                       ect_status: v.job_roles&.include?(3) ? :ect_suitable : :ect_unsuitable
    end
  end

  # TODO: remove phase field from vacancies table once this is done
  desc "Set phases from schools or old readable_phases field"
  task set_new_phases: :environment do
    Vacancy.find_each do |v|
      phases =
        if v.school_phases.any?
          v.school_phases.map { |p| Vacancy.phases[p] }
        else
          v.readable_phases.map { |p| p.in?(["16-19", "16 to 19"]) ? 4 : Vacancy.phases[p] }
        end
      v.update_column :phases, phases
    end
  end

  desc "Asynchronously import organisations from GIAS and seed the database"
  task async_seed: :environment do
    SeedDatabaseJob.perform_later
  end

  desc "Reset markers"
  task reset_markers: :environment do
    Vacancy.published.applicable.find_each(&:reset_markers)
  end

  desc "Generates 1000 random vacancies for testing purposes"
  task create_random_vacancies: :environment do
    1000.times do
      school = School.not_closed.order(Arel.sql("RANDOM()")).first
      FactoryBot.create(:vacancy, organisations: [school])
    end
  end

  desc "Add FriendlyId slugs to Organisation records"
  task add_friendlyid_organisation_slugs: :environment do
    SetOrganisationSlugsJob.perform_now
  end

  desc "Set other_start_date_details and start_date_type for vacancies"
  task set_start_date_fields: :environment do
    Vacancy.find_each do |v|
      start_date_type =
        if v.starts_asap
          "other"
        elsif v.starts_on.present?
          "specific_date"
        else
          "undefined"
        end

      v.update_column :start_date_type, start_date_type

      if v.starts_asap
        other_start_date_details = "As soon as possible"
        v.update_column :other_start_date_details, other_start_date_details
      end
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
