namespace :db do
  namespace :migrate do
    desc "Run db:migrate but ignore ActiveRecord::ConcurrentMigrationError errors"
    task ignore_concurrent_migration_exceptions: :environment do
      Rake::Task["db:migrate"].invoke
    rescue ActiveRecord::ConcurrentMigrationError
      # Do nothing
    end
  end

  namespace :prepare do
    desc "Run db:prepare but ignore ActiveRecord::ConcurrentMigrationError errors"
    task ignore_concurrent_migration_exceptions: :environment do
      if ActiveRecord::Base.connection.tables.empty?
        Rake::Task["db:schema:load"].invoke
      end
      Rake::Task["db:migrate"].invoke
    rescue ActiveRecord::ConcurrentMigrationError
      # Do nothing
    end
  end
end
