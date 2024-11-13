OnlineMigrations.configure do |config|
  # Configure the migration version starting after which checks are performed.
  config.start_after = 20230710104904 # rubocop:disable Style/NumericLiterals

  # Set the version of the production database so the right checks are run in development.
  config.target_version = 12

  # Configure whether to perform checks when migrating down.
  config.check_down = false

  # Configure custom error messages.
  # error_messages is a Hash with keys - error names and values - error messages.
  # config.error_messages[:remove_column] = "Your custom instructions"

  # Maximum allowed lock timeout value (in seconds).
  # If set lock timeout is greater than this value, the migration will fail.
  # config.lock_timeout_limit = 10.seconds

  # Configure list of tables with permanently small number of records.
  # This tables are usually tables like "settings", "prices", "plans" etc.
  # It is considered safe to perform most of the dangerous operations on them.
  config.small_tables = %w[emergency_login_keys support_users]

  # Disable specific checks.
  # For the list of available checks look at `lib/error_messages` folder.
  # config.disable_check(:remove_index)

  # Enable specific checks. All checks are enabled by default,
  # but this may change in the future.
  # For the list of available checks look at `lib/error_messages` folder.
  # config.enable_check(:remove_index)

  # Configure whether to log every SQL query happening in a migration.
  #
  # This is useful to demystify online_migrations inner workings, and to better investigate
  # migration failure in production. This is also useful in development to get
  # a better grasp of what is going on for high-level statements like add_column_with_default.
  #
  # Note: It can be overridden by `ONLINE_MIGRATIONS_VERBOSE_SQL_LOGS` environment variable.
  config.verbose_sql_logs = defined?(Rails) && Rails.env.production?

  # Lock retries.
  # Configure your custom lock retrier (see LockRetrier).
  # To disable lock retries, set `lock_retrier` to `nil`.
  config.lock_retrier = OnlineMigrations::ExponentialLockRetrier.new(
    attempts: 30,                # attempt 30 retries
    base_delay: 0.01.seconds,    # starting with delay of 10ms between each unsuccessful try, increasing exponentially
    max_delay: 1.minute,         # up to the maximum delay of 1 minute
    lock_timeout: 0.05.seconds, # and 50ms set as lock timeout for each try
  )

  # Configure tables that are in the process of being renamed.
  # config.table_renames["users"] = "clients"

  # Configure columns that are in the process of being renamed.
  # config.column_renames["users] = { "name" => "first_name" }

  # Add custom checks. Use the `stop!` method to stop migrations.
  #
  # config.add_check do |method, args|
  #   if method == :add_column && args[0].to_s == "users"
  #     stop!("No more columns on the users table")
  #   end
  # end

  # ==> Background migrations configuration
  # The number of rows to process in a single background migration run.
  # config.background_migrations.batch_size = 20_000

  # The smaller batches size that the batches will be divided into.
  # config.background_migrations.sub_batch_size = 1000

  # The pause interval between each background migration job's execution (in seconds).
  # config.background_migrations.batch_pause = 0.seconds

  # The number of milliseconds to sleep between each sub_batch execution.
  # config.background_migrations.sub_batch_pause_ms = 100

  # Maximum number of batch run attempts.
  # When attempts are exhausted, the individual batch is marked as failed.
  # config.background_migrations.batch_max_attempts = 5

  # Configure custom throttler for background migrations.
  # It will be called before each batch run.
  # If throttled, the current run will be retried next time.
  # config.background_migrations.throttler = -> { DatabaseStatus.unhealthy? }

  # The number of seconds that must pass before the running job is considered stuck.
  # config.background_migrations.stuck_jobs_timeout = 1.hour

  # The Active Support backtrace cleaner that will be used to clean the
  # backtrace of a migration job that errors.
  config.background_migrations.backtrace_cleaner = Rails.backtrace_cleaner

  # The callback to perform when an error occurs in the migration job.
  # config.background_migrations.error_handler = ->(error, errored_job) do
  #   Bugsnag.notify(error) do |notification|
  #     notification.add_metadata(:background_migration, { name: errored_job.migration_name })
  #   end
  # end

  # Migration Timeouts
  #
  # It’s extremely important to set a short lock timeout for migrations. This way, if a migration can't acquire a lock
  # in a timely manner, other statements won't be stuck behind it.
  # We also recommend setting a long statement timeout so migrations can run for a while.
  #
  config.statement_timeout = 1.hour
end
