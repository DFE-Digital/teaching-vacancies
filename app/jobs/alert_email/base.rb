class AlertEmail::Base < ApplicationJob
  MAXIMUM_RESULTS_PER_RUN = 500

  def perform
    return if DisableEmailNotifications.enabled?

    # The intent here is that if we don't have keyword or location searches, then this operation can all be done in memory
    # really fast (1 week's worth of vacancies is around 2000, so not worth leaving on disk for each of 100k daily subscriptions
    default_scope = Vacancy.includes(:organisations).live.order(publish_on: :desc).search_by_filter(from_date: from_date, to_date: Date.yesterday).to_a

    already_run_ids = Set.new AlertRun.for_today.pluck(:subscription_id)

    subscriptions.find_each.reject { |sub| already_run_ids.include?(sub.id) }.each do |subscription|
      vacancies = subscription.vacancies_matching(default_scope).first(MAXIMUM_RESULTS_PER_RUN)

      next if subscription.reload.email.blank?

      Jobseekers::AlertMailer.alert(subscription.id, vacancies.pluck(:id)).deliver_later if vacancies.any?
    end
    Sentry.capture_message("#{self.class.name} run successfully", level: :info)
  end
end
