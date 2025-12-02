desc "Migrate personal_statement data to rich_text content field using background jobs"
task migrate_personal_statement_to_content: :environment do
  migrate_job_applications_in_batches
end

def migrate_job_applications_in_batches
  JobApplication.find_in_batches(batch_size: 1000) do |batch|
    MigratePersonalStatementJob.perform_later(batch.pluck(:id))
  end
end
