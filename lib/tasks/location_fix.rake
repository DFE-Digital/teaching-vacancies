desc "Fix missing location search criteria"
task :location_fix, %i[filename commit] => [:environment] do |_, args|
  filename = args[:filename]
  commit = (args[:commit] == "true")

  Rails.logger.info("[DRY RUN]") unless commit

  # Parse Bigquery JSON export into an array of hashes
  bq_data = JSON.parse(File.read(filename))
                .map { |item| item["data"] }
                .map { |item| item.map { |subitem| [subitem["key"], subitem["value"]] }.to_h }

  last_good_backup_time = Time.zone.parse("2021-02-02 05:00:00")
  bad_task_ran_time = Time.zone.parse("2021-02-03 14:06:00")

  # Find subscriptions affected by the bug, and create a mapping hash of anonymised subscription
  # IDs to actual IDs ()so we can correlate Bigquery events with subscriptions in the database)
  affected_subscriptions = Subscription
                             .active
                             .where(created_at: last_good_backup_time..bad_task_ran_time)
                             .to_h { |sub| [StringAnonymiser.new(sub.id).to_s, sub] }
  Rails.logger.info("Found #{affected_subscriptions.size} affected subscriptions")

  bq_data.each do |event|
    anonymised_id = event["subscription_identifier"]
    # Convert criteria which is sent to Bigquery as a (mistakenly) stringified hash into a real hash
    new_search_criteria = JSON.parse(event["search_criteria"].gsub("=>", ":").gsub(":nil", ":null"))

    # Try and find a subscription in our mapping that matches the anonymised ID from the event
    if affected_subscriptions.key?(anonymised_id)
      subscription = affected_subscriptions[anonymised_id]

      Rails.logger.info("Found subscription #{subscription.id} for anonymised ID #{anonymised_id}")
      Rails.logger.info("Current search_criteria: #{subscription.search_criteria}")

      # Do a dry run unless we explicitly want to go ahead
      if commit
        subscription.update(search_criteria: new_search_criteria)
        Rails.logger.info("We have updated search_criteria to: #{new_search_criteria}")
      else
        Rails.logger.info("We would update search_criteria to: #{new_search_criteria}")
      end
    else
      Rails.logger.error("No subscription found for anonymised ID #{anonymised_id}")
    end
  end
end
