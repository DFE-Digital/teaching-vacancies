require 'performance_platform'
class PerformancePlatformTransactionsQueueJob < ApplicationJob
  queue_as :performance_platform

  def perform(time_to_s)
    date = Time.zone.parse(time_to_s)

    return if TransactionAuditor::Logger.new('performance_platform:submit_transactions', date).performed?

    no_of_transactions = Vacancy.published_on_count(date)
    PerformancePlatform::TransactionsByChannel.new(PP_TRANSACTIONS_BY_CHANNEL_TOKEN)
                                              .submit_transactions(no_of_transactions, date.utc.iso8601)

    TransactionAuditor::Logger.new('performance_platform:submit_transactions', date).log_success
  rescue StandardError => e
    TransactionAuditor::Logger.new('performance_platform:submit_transactions', date).log_failure
    Rails.logger.error("Sidekiq: Something went wrong and transactions were not submitted \
                        to the Performance Platform: #{e.message}")
    raise
  end
end
