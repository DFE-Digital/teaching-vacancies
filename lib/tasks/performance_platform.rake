require "performance_platform"

namespace :performance_platform do
  desc "Performance Platform transaction submission"
  task submit: :environment do
    Rake::Task["performance_platform:submit_transactions"].invoke
  end

  desc "Performance Platform transaction submission"
  task submit_transactions: :environment do
    yesterday = Date.current.beginning_of_day.in_time_zone - 1.day
    PerformancePlatformTransactionsQueueJob.perform_later(yesterday.to_s)
  end

  desc "Performance Platform submit data up to today transaction"
  task submit_data_up_to_today: :environment do
    start_date = Date.parse("20/04/2018")
    current_date = Date.current
    number_of_days = current_date.mjd - start_date.mjd

    while number_of_days.positive?
      date = Date.current.beginning_of_day.in_time_zone - number_of_days.day
      PerformancePlatformTransactionsQueueJob.perform_later(date.to_s)
      number_of_days -= 1
    end
  end
end
