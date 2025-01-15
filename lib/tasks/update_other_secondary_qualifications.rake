namespace :qualifications do
  desc "Migrate other_secondary qualifications to other category"
  task migrate_to_other: :environment do
    QualificationsMigration.perform
    puts "Migration completed successfully."
  rescue StandardError => e
    puts "Migration failed: #{e.message}"
  end
end
