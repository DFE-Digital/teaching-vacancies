require 'performance_platform'
class PerformancePlatformTransactionsQueueJob < ApplicationJob
  queue_as :default

  def perform(date)
    return if TransactionAuditor::Logger.new('performance_platform:submit_transactions', date).performed?
    no_of_transactions = Vacancy.published_on_count(date)
    performance_platform = PerformancePlatform::TransactionsByChannel.new(PP_TRANSACTIONS_BY_CHANNEL_TOKEN)
    performance_platform.submit_transactions(no_of_transactions, date.utc.iso8601)

    TransactionAuditor::Logger.new('performance_platform:submit_transactions', date).log_success
  rescue StandardError => e
    TransactionAuditor::Logger.new('performance_platform:submit_transactions', date).log_failure
    Rollbar.log(:error,
                'Something went wrong and transactions were not submitted to the Performance Platform',
                e.message)
  end
end
