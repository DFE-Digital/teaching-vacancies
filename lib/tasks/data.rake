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

namespace :google_drive do
  desc "Delete old documents"
  task :delete_old_documents, [:commit] => [:environment] do |_task, args|
    delete_before = Date.new(2020, 0o6, 15)

    documents = Document.includes(:vacancy).where("documents.created_at <?", delete_before)

    puts "Found #{documents.count} documents to delete that were created before #{delete_before}"

    next unless args[:commit] == "true"

    puts "Get ready to delete them!"
    documents_deleted = 0

    documents.find_each do |document|
      vacancy = document.vacancy
      if vacancy.published? && vacancy.expires_at.future?
        puts "NOT deleting document name:#{document.name} size:#{document.size} from published vacancy #{document.vacancy.id}"
        next
      end

      puts "Deleting document name:#{document.name} size:#{document.size}"

      DocumentDelete.new(document).delete
      documents_deleted += 1

      puts "Deleted document name:#{document.name} size:#{document.size}"
    end

    puts "#{documents_deleted} Documents deleted. Have a good day!"
  end
end
