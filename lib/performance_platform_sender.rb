require 'performance_platform'

module PerformancePlatformSender
  class Base
    def self.by_type(type)
      const_get('PerformancePlatformSender::' + type.to_s.capitalize).new
    end

    def call(date:)
      @date = Time.zone.parse(date)

      return if TransactionAuditor::Logger.new(log_source, date).performed?

      send_data

      TransactionAuditor::Logger.new(log_source, date).log_success
    rescue StandardError => e
      TransactionAuditor::Logger.new(log_source, date).log_failure
      Rails.logger.error("Something went wrong and #{performance_type} were not submitted \
                          to the Performance Platform: #{e.message}")
      raise
    end

    private

    attr_reader :date

    def performance_type
      self.class.name.demodulize
    end
  end

  class Transactions < Base
    private

    def log_source
      'performance_platform:submit_transactions'
    end

    def send_data
      PerformancePlatform::TransactionsByChannel
        .new(PP_TRANSACTIONS_BY_CHANNEL_TOKEN)
        .submit(data, date.iso8601)
    end

    def data
      Vacancy.published_on_count(date)
    end
  end

  class Feedback < Base
    private

    def log_source
      'performance_platform:submit_user_satisfaction'
    end

    def send_data
      PerformancePlatform::UserSatisfaction
        .new(PP_USER_SATISFACTION_TOKEN)
        .submit(data, date.iso8601)
    end

    def data
      { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
        .merge!(VacancyPublishFeedback.published_on(date).group(:rating).count) { |_, old, new| old + new }
    end
  end
end
