require 'performance_platform'

namespace :performance_platform do
  desc 'Performance Platform transaction submission'
  task :submit do
    Rake::Task['performance_platform:submit_transactions'].invoke
  end

  task submit_transactions: :environment do
    begin
      performance_platform = PerformancePlatform::TransactionsByChannel.new(PP_TRANSACTIONS_BY_CHANNEL_TOKEN)
      time_now = Time.zone.now
      no_of_transactions = Vacancy.published_on_count(time_now - 1.day)
      performance_platform.submit_transactions(no_of_transactions, (time_now - 1.day).utc.iso8601)
      Rollbar.log(:info,
                  "Performance Platform transactions for #{time_now - 1.day}: #{no_of_transactions}")
    rescue StandardError => e
      Rollbar.log(:error,
                  'Something went wrong and transactions were not submitted to the Performance Platform',
                  e.message)
    end
  end
end
