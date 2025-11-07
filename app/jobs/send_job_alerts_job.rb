class SendJobAlertsJob < ApplicationJob
  queue_as :verylow

  MAXIMUM_RESULTS_PER_RUN = 500

  # rubocop:disable Metrics/MethodLength
  def perform(name, subscriptions, from_date)
    # For stats tracking on each run
    start_time = Time.current
    sent_alerts_count = 0
    vacancies_in_alerts_count = 0
    subscriptions_count = subscriptions.count

    default_scope = PublishedVacancy.live.search_by_filter(from_date: from_date, to_date: Date.current)

    # for stats tracking on each run
    new_vacancies_count = default_scope.size

    already_run_ids = Set.new AlertRun.for_today.pluck(:subscription_id)

    subscriptions.each.reject { |sub| already_run_ids.include?(sub.id) }.each do |subscription|
      matching_vacancy_ids = subscription.vacancies_matching(default_scope, limit: MAXIMUM_RESULTS_PER_RUN)
      next unless matching_vacancy_ids.any?
      next if subscription.email.blank?

      sent_alerts_count += 1
      vacancies_in_alerts_count += matching_vacancy_ids.size
      Jobseekers::AlertMailer.alert(subscription.id, matching_vacancy_ids).deliver_later
    end
    log_to_sentry(name: name,
                  duration: Time.current - start_time,
                  new_vacancies_count:,
                  subscriptions_count:,
                  vacancies_in_alerts_count:,
                  sent_alerts_count:)
  end
  # rubocop:enable Metrics/MethodLength

  private

  def log_to_sentry(name:, duration:, new_vacancies_count:, subscriptions_count:, vacancies_in_alerts_count:, sent_alerts_count:)
    formatted_duration = format_duration(duration)
    Sentry.with_scope do |scope|
      scope.set_context("Alert run Statistics", { duration: formatted_duration,
                                                  new_vacancies_count:,
                                                  subscriptions_count:,
                                                  sent_alerts_count:,
                                                  vacancies_in_alerts_count: })
      Sentry.capture_message(
        "#{name} run successfully (duration: #{formatted_duration})",
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
