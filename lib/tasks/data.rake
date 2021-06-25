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

namespace :subscriptions do
  desc "Fix subscriptions with wrong email"
  task fix_wrong_email: :environment do
    subscriptions_to_fix = Subscription.where("email LIKE '%.con' AND created_at > ?", 3.months.ago)

    puts "Checking #{subscriptions_to_fix.count} subscriptions having email ending in .con created in the last 3 months"

    fixed_subscriptions_count = 0
    deleted_subscriptions_count = 0

    subscriptions_to_fix.find_each do |subscription|
      if Subscription.find_by(email: subscription.email.gsub(/\.con$/, ".com"))
        subscription.destroy
        deleted_subscriptions_count += 1
      else
        subscription.update_column(:email, subscription.email.gsub(/\.con$/, ".com"))
        fixed_subscriptions_count += 1
      end
    end

    old_wrong_subscriptions_to_be_delete = Subscription.where("email LIKE '%.con' AND created_at < ?", 3.months.ago)
    old_wrong_subscriptions_to_be_delete_count = old_wrong_subscriptions_to_be_delete.count
    old_wrong_subscriptions_to_be_delete.destroy_all

    puts "Fixed #{fixed_subscriptions_count} subscriptions having email ending with .con"
    puts "Deleted #{deleted_subscriptions_count} subscriptions with an email ending with .con when the user has later created a subscription with the correct email address"
    puts "Also deleted #{old_wrong_subscriptions_to_be_delete_count} subscriptions created more than 3 months ago with an email ending with .con"
    puts "Have a nice day!"
  end
end
