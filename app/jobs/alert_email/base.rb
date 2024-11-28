class AlertEmail::Base < ApplicationJob
  MAXIMUM_RESULTS_PER_RUN = 500

  FILTERS = {
    teaching_job_roles: ->(vacancy, value) { (vacancy.job_roles & value).any? },
    support_job_roles: ->(vacancy, value) { (vacancy.job_roles & value).any? },
    visa_sponsorship_availability: ->(vacancy, value) { value.include? vacancy.visa_sponsorship_available.to_s },
    ect_statuses: ->(vacancy, value) { value.include?(vacancy.ect_status) },
    subjects: ->(vacancy, value) { (vacancy.subjects & value).any? },
    phases: ->(vacancy, value) { (vacancy.phases & value).any? },
    working_patterns: ->(vacancy, value) { (vacancy.working_patterns & value).any? },
    organisation_slug: ->(vacancy, value) { vacancy.organisations.map(&:slug).include?(value) },
    keyword: ->(vacancy, value) { vacancy.searchable_content.include? value.downcase.strip },
  }.freeze

  def perform # rubocop:disable Metrics/AbcSize
    return if DisableExpensiveJobs.enabled?

    # The intent here is that if we don't have keyword or location searches, then this operation can all be done in memory
    # really fast (1 week's worth of vacancies is around 2000, so not worth leaving on disk for each of 100k daily subscriptions
    default_scope = Vacancy.includes(:organisations).live.order(publish_on: :desc).search_by_filter(from_date: from_date, to_date: Date.current)

    already_run_ids = AlertRun.for_today.map(&:subscription_id)

    subscriptions.find_each.reject { |sub| already_run_ids.include?(sub.id) }.each do |subscription|
      scope = default_scope
      criteria = subscription.search_criteria.symbolize_keys
      scope, criteria = handle_location(scope, criteria)

      vacancies = scope.select do |vacancy|
        criteria.all? { |criterion, value| FILTERS.fetch(criterion).call(vacancy, value) }
      end

      Jobseekers::AlertMailer.alert(subscription.id, vacancies.pluck(:id)).deliver_later if vacancies.any?
    end
    Sentry.capture_message("#{self.class.name} run successfully", level: :info)
  end

  private

  def handle_location(scope, criteria)
    if criteria.key?(:location)
      [scope.search_by_location(criteria[:location], criteria[:radius]), criteria.except(:location, :radius)]
    else
      [scope, criteria]
    end
  end
end
