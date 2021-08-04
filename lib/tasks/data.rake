namespace :algolia do
  desc "Load an index with live records for the first time"
  task reindex: :environment do
    Vacancy.reindex!
  end

  desc "Remove Algolia primary index and replicas"
  task remove_indices: :environment do
    replicas = Vacancy.index.get_settings["replicas"]
    Vacancy.index.set_settings({ replicas: [] })
    Algolia.client.delete_index(Indexable::INDEX_NAME)
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
    require "organisation_import/import_school_data"
    require "organisation_import/import_trust_data"

    ImportOrganisationData.mark_all_school_group_memberships_to_be_deleted!
    ImportSchoolData.new.run!
    ImportTrustData.new.run!
    ImportOrganisationData.delete_marked_school_group_memberships!
  end
end

namespace :ons do
  desc "Import all location polygons"
  task import_location_polygons: :environment do
    %i[regions counties cities].each { |api_location_type| ImportPolygons.new(api_location_type: api_location_type).call }
  end
end

namespace :vacancy_completed_steps do
  desc "Migrate completed step data from integer to array of strings"
  task migrate: :environment do
    steps_config = {
      job_location: "1",
      schools: "1",
      job_details: "2",
      pay_package: "3",
      important_dates: "4",
      documents: "5",
      applying_for_the_job: "6",
      job_summary: "7",
      review: "8",
    }.freeze

    Vacancy.find_each(batch_size: 100) do |vacancy|
      completed_steps = vacancy.completed_steps | steps_config.select { |_step, number|
        number.to_i == vacancy.completed_step
      }.keys.map(&:to_s)
      vacancy.update(completed_steps: completed_steps)
    end
  end
end
