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
    ImportOrganisationDataJob.perform_now
  end
end

namespace :ons do
  desc "Import all location polygons"
  task import_location_polygons: :environment do
    %i[regions counties cities].each { |api_location_type| ImportPolygons.new(api_location_type: api_location_type).call }
  end
end

namespace :fix_subscriptions do
  desc "Fix subscriptions search criteria by updating NQT working pattern to ECT"
  task fix_nqt_suitable: :environment do
    nqt_suitable_string = "nqt_suitable"
    Subscription.find_each(batch_size: 100) do |subscription|
      criteria = subscription.search_criteria
      job_roles = criteria["job_roles"]
      if job_roles&.include?(nqt_suitable_string)
        job_roles.delete(nqt_suitable_string)
        job_roles.push("ect_suitable")
        criteria["job_roles"] = job_roles
        subscription.update_columns(search_criteria: criteria)
      end
    end
  end
end
