class AlertEmail::Base < ApplicationJob
  MAXIMUM_RESULTS_PER_RUN = 500

  # rubocop:disable Metrics/AbcSize
  def perform
    return if DisableEmailNotifications.enabled?

    # For stats tracking on each run
    start_time = Time.current
    emails_count = 0
    vacancies_count = 0

    # The intent here is that if we don't have keyword or location searches, then this operation can all be done in memory
    # really fast (1 week's worth of vacancies is around 2000, so not worth leaving on disk for each of 100k daily subscriptions
    default_scope = PublishedVacancy.includes(:organisations).live.order(publish_on: :desc).search_by_filter(from_date: from_date, to_date: Date.yesterday).to_a

    already_run_ids = Set.new AlertRun.for_today.pluck(:subscription_id)

    subscriptions.find_each.reject { |sub| already_run_ids.include?(sub.id) }.each do |subscription|
      vacancies = subscription.vacancies_matching(default_scope).first(MAXIMUM_RESULTS_PER_RUN)
      next unless vacancies.any?
      next if subscription.email.blank?

      emails_count += 1
      vacancies_count += vacancies.size
      Jobseekers::AlertMailer.alert(subscription.id, vacancies.pluck(:id)).deliver_later
    end
    log_to_sentry(duration: Time.current - start_time, vacancies_count:, emails_count:)
  end
  # rubocop:enable Metrics/AbcSize

  private

  def log_to_sentry(duration:, vacancies_count:, emails_count:)
    formatted_duration = format_duration(duration)
    Sentry.with_scope do |scope|
      scope.set_context("Alert run Statistics", { duration: formatted_duration,
                                                  alerts_sent: emails_count,
                                                  vacancies_in_alerts: vacancies_count })
      Sentry.capture_message(
        "#{self.class.name} run successfully (duration: #{formatted_duration})",
        level: :info,
        fingerprint: ["{{ transaction }}"], # Groups Sentry messages by transaction. EG: Sidekiq/SendDailyAlertEmailJob
      )
    end
  end

  def format_duration(seconds)
    total_seconds = seconds.to_i
    minutes = total_seconds / 60
    secs = total_seconds % 60
    "#{minutes}m #{secs}s"
  end
end
