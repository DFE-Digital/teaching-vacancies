require 'performance_platform'
class PerformancePlatformFeedbackQueueJob < ApplicationJob
  queue_as :default

  def perform(time_to_s)
    date = Time.zone.parse(time_to_s)
    return if TransactionAuditor::Logger.new('performance_platform:submit_user_satisfaction', date).performed?
    data = { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }.merge!(Feedback.published_on(date).group(:rating).count)
    PerformancePlatform::UserSatisfaction.new(PP_USER_SATISFACTION_TOKEN)
                                         .submit(data, date.utc.iso8601)
    TransactionAuditor::Logger.new('performance_platform:submit_user_satisfaction', date).log_success
  rescue StandardError => e
    TransactionAuditor::Logger.new('performance_platform:submit_user_satisfaction', date).log_failure
    Rails.logger.error("Sidekiq: Something went wrong and user satisfaction was not \
                       submitted to the Performance Platform': #{e.message}")
    raise
  end
end
