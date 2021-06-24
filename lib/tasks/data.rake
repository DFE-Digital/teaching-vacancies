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

namespace :feedbacks do
  desc "Copy application_id to job_application_id"
  task copy_application_id_to_job_application_id: :environment do
    feedbacks_to_fix_count = Feedback.where.not(application_id: nil).where(job_application_id: nil).count
    fixed_feedbacks_count = 0

    puts "Checking #{feedbacks_to_fix_count} feedbacks with application_id set and job_application_id nil..."

    Feedback.find_each do |feedback|
      next unless feedback.application_id.present? && feedback.job_application_id.blank?

      feedback.update_column(:job_application_id, feedback.application_id)
      fixed_feedbacks_count += 1
    end

    puts "Fixed #{fixed_feedbacks_count} feedbacks."
    puts "⛅ Have a nice day!"
  end
end
