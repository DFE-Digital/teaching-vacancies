require "performance_platform"

module PerformancePlatformSender
  class Base
    def self.by_type(type)
      const_get("PerformancePlatformSender::#{type.to_s.capitalize}").new
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
      "performance_platform:submit_transactions"
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
end
