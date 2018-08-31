require 'performance_platform'
class PerformancePlatformFeedbackQueueJob < ApplicationJob
  queue_as :default

  def perform(date)
    return if TransactionAuditor::Logger.new('performance_platform:submit_user_satisfaction', date).performed?

    data = { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
    feedback_counts = Feedback.published_on(date).group(:rating).count
    data.merge!(feedback_counts)

    user_satisfaction = PerformancePlatform::UserSatisfaction.new(PP_USER_SATISFACTION_TOKEN)
    user_satisfaction.submit(data, date.utc.iso8601)

    TransactionAuditor::Logger.new('performance_platform:submit_user_satisfaction', date).log_success
  rescue StandardError => e
    TransactionAuditor::Logger.new('performance_platform:submit_user_satisfaction', date).log_failure
    Rollbar.log(:error,
                'Something went wrong and user satisfaction was not submitted to the Performance Platform',
                e.message)
  end
end
