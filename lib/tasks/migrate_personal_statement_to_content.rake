desc "Migrate personal_statement data to rich_text content field using background jobs"
task migrate_personal_statement_to_content: :environment do
  scope = JobApplication.where.not(personal_statement_ciphertext: [nil, ""])
                        .left_joins(:rich_text_content)
                        .where(action_text_rich_texts: { id: nil })

  scope.find_in_batches(batch_size: 1000) do |batch|
    MigratePersonalStatementBatchJob.perform_later(batch.pluck(:id))
  end
end
