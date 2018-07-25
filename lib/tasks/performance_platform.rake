require 'performance_platform'

namespace :performance_platform do
  desc 'Performance Platform transaction submission'
  task submit: :environment do
    Rake::Task['performance_platform:submit_transactions'].invoke
    Rake::Task['performance_platform:submit_user_satisfaction'].invoke
  end

  task submit_transactions: :environment do
    Rails.logger.debug('here')
    begin
      time_now = DateTime.current.beginning_of_day
      no_of_transactions = Vacancy.published_on_count(time_now - 1.day)

      performance_platform = PerformancePlatform::TransactionsByChannel.new(PP_TRANSACTIONS_BY_CHANNEL_TOKEN)
      performance_platform.submit_transactions(no_of_transactions, (time_now - 1.day).utc.iso8601)

      Rollbar.log(:info,
                  "Performance Platform transactions for #{time_now - 1.day}: #{no_of_transactions}")
    rescue StandardError => e
      Rollbar.log(:error,
                  'Something went wrong and transactions were not submitted to the Performance Platform',
                  e.message)
    end
  end

  task submit_user_satisfaction: :environment do
    begin
      time_now = DateTime.current.beginning_of_day
      data = { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
      feedback_counts = Feedback.published_on(time_now - 1.day).group(:rating).count
      data.merge!(feedback_counts)

      user_satisfaction = PerformancePlatform::UserSatisfaction.new(PP_USER_SATISFACTION_TOKEN)
      user_satisfaction.submit(data, (time_now - 1.day).utc.iso8601)

      Rollbar.log(:info,
                  "Performance Platform user satisfaction for #{time_now - 1.day}: #{data}")
    rescue StandardError => e
      Rollbar.log(:error,
                  'Something went wrong and user satisfaction was not submitted to the Performance Platform',
                  e.message)
    end
  end
end
