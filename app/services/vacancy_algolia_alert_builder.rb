class VacancyAlgoliaAlertBuilder < VacancyAlgoliaSearchBuilder
  attr_accessor :subscription_hash, :filter_array

  MAXIMUM_SUBSCRIPTION_RESULTS = 500

  def initialize(subscription_hash)
    self.subscription_hash = subscription_hash
    self.keyword = subscription_hash[:keyword] || build_subscription_keyword(subscription_hash)

    self.location_filter = {}
    self.search_filter = 'listing_status:published AND '\
                         "publication_date_timestamp <= #{published_today_filter} AND "\
                         "expires_at_timestamp > #{expired_now_filter}"
    self.filter_array = []

    build_subscription_filters(subscription_hash)
    build_search_filter
    initialize_sort_by(subscription_hash[:jobs_sort])
    initialize_location(subscription_hash[:location_category], subscription_hash[:location], subscription_hash[:radius])
    initialize_search
  end

  def call
    self.vacancies = Vacancy.search(
      search_query,
      aroundLatLng: location_filter[:coordinates],
      aroundRadius: location_filter[:radius],
      replica: search_replica,
      hitsPerPage: MAXIMUM_SUBSCRIPTION_RESULTS,
      filters: search_filter,
      typoTolerance: false
    )
    Rails.logger.info(
      "#{vacancies.count} vacancies found for job alert with criteria: #{subscription_hash}, "\
      "search_query: #{search_query}, replica: #{search_replica}, location_filter: #{location_filter} "\
      "and filters: #{search_filter}"
    )
    vacancies
  end

  private

  def build_subscription_filters(subscription_hash)
    dates = "publication_date_timestamp >= #{subscription_hash[:from_date].to_datetime.to_i} AND "\
            "publication_date_timestamp <= #{subscription_hash[:to_date].to_datetime.to_i}"

    working_patterns = subscription_hash[:working_patterns]&.map {
      |working_pattern| "working_patterns:#{working_pattern}"
    }&.join(' OR ')

    job_roles = "job_roles:'#{I18n.t('jobs.job_role_options.nqt_suitable')}'" if
      subscription_hash[:newly_qualified_teacher] == 'true'

    phases = subscription_hash[:phases]&.map {
      |phase| "school.phase:#{phase}"
    }&.join(' OR ')

    build_filter_array(dates, working_patterns, job_roles, phases)
  end

  def build_filter_array(dates, working_patterns, job_roles, phases)
    self.filter_array << "(#{search_filter})"
    self.filter_array << "(#{dates})"
    self.filter_array << "(#{working_patterns})" if working_patterns.present?
    self.filter_array << "(#{job_roles})" if job_roles.present?
    self.filter_array << "(#{phases})" if phases.present?
  end

  def build_search_filter
    self.search_filter = filter_array.reject(&:blank?).join(' AND ')
  end

  def build_subscription_keyword(subscription_hash)
    [subscription_hash[:subject], subscription_hash[:job_title]].reject(&:blank?).join(' ')
  end
end
