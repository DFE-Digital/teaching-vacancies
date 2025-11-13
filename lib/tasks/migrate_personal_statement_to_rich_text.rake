namespace :data do
  desc "Migrate personal_statement data to rich_text content field using background jobs"
  task migrate_personal_statement_to_content: :environment do
    # Only get records that have personal_statement but no content
    scope = JobApplication.where.not(personal_statement_ciphertext: [nil, ""])

    puts "About to migrate #{scope.count} job applications"
    scope.find_in_batches(batch_size: 1000) do |batch|
      MigratePersonalStatementBatchJob.perform_later(batch.pluck(:id))
    end

    puts "Migration jobs queued"
  end
end
