class SendJobAlertsJob < ApplicationJob
  queue_as :jobalerts

  # Concurrency is limited per job here rather than via worker threads in config/queue.yml, because the
  # jobalerts queue runs one thread per pod, so only a per-job limit caps concurrency across all pods.
  #
  # Alerts are enqueued in batches of 5000 subscriptions, so tens of these jobs land at once, and each
  # runs heavy subscription/vacancy matching queries. Unthrottled they have driven DB CPU to 90-100%
  # and crashed the service; at a limit of 2 the same run peaks at 20-30%. Alerts are not time critical,
  # so the few minutes of delay this adds costs jobseekers nothing. Measure DB CPU over a full run
  # before raising the limit.
  #
  # `duration` is not a job timeout: it is the expiry on the concurrency semaphore, a failsafe for a
  # worker that dies without releasing it. Keep it well above the slowest single run, as an expired
  # semaphore is deleted while jobs are still running and lets extra jobs through.
  limits_concurrency to: 2, key: :send_job_alerts, duration: 10.minutes

  MAXIMUM_RESULTS_PER_RUN = 500

  def perform(name, subscriptions, from_date) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # For stats tracking on each run
    start_time = Time.current
    sent_alerts_count = 0
    vacancies_in_alerts_count = 0
    subscriptions_count = subscriptions.count

    default_scope = PublishedVacancy.live.where(publish_on: from_date..Date.yesterday)

    # for stats tracking on each run
    new_vacancies_count = default_scope.size

    already_run_ids = Set.new AlertRun.for_today.pluck(:subscription_id)

    subscriptions.each.reject { |sub| already_run_ids.include?(sub.id) }.each do |subscription|
      matching_vacancies = subscription.vacancies_matching(default_scope, limit: MAXIMUM_RESULTS_PER_RUN)
      next unless matching_vacancies.any?
      next if subscription.email.blank?

      sent_alerts_count += 1
      vacancies_in_alerts_count += matching_vacancies.size
      Jobseekers::AlertMailer.alert(subscription.id, matching_vacancies.pluck(:id)).deliver_later
    end
    log_to_sentry(name: name,
                  duration: Time.current - start_time,
                  new_vacancies_count:,
                  subscriptions_count:,
                  vacancies_in_alerts_count:,
                  sent_alerts_count:)
  end

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
        fingerprint: ["{{ transaction }}"], # Groups Sentry messages by transaction. EG: SendDailyAlertEmailJob
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
