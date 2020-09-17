class Algolia::VacancyFiltersBuilder
  def initialize(filters_hash)
    # Although we are no longer indexing expired and pending vacancies, we need to maintain this filter for now as
    # expired vacancies only get removed from the index once a day.
    @live_filter = 'listing_status:published AND '\
                   "publication_date_timestamp <= #{published_today_filter} AND "\
                   "expires_at_timestamp > #{expired_now_filter}"

    @from_date = filters_hash[:from_date]
    @to_date = filters_hash[:to_date]

    @job_roles = filters_hash[:job_roles]
    # Legacy filters included phases, so legacy URLs may contain empty arrays here
    @phases = filters_hash[:phases]&.reject(&:blank?)
    @working_patterns = filters_hash[:working_patterns]

    @suitable_for_nqt = filters_hash[:newly_qualified_teacher]
  end

  def filter_query
    build_filters

    filter_array = []
    filter_array << "(#{@live_filter})"
    filter_array << "(#{@dates_filter})" if @dates_filter.present?
    filter_array << "(#{@job_roles_filter})" if @job_roles_filter.present?
    filter_array << "(#{@phases_filter})" if @phases_filter.present?
    filter_array << "(#{@working_patterns_filter})" if @working_patterns_filter.present?
    filter_array << "(#{@suitable_for_nqt_filter})" if @suitable_for_nqt_filter.present?

    filter_array.reject(&:blank?).join(' AND ')
  end

private

  def build_filters
    @dates_filter = build_date_filters
    @job_roles_filter = @job_roles&.map { |job_role| build_filter_string('job_roles', job_role) }&.join(' OR ')
    @phases_filter = @phases&.map { |phase| build_filter_string('education_phases', phase) }&.join(' OR ')
    @working_patterns_filter = @working_patterns&.map { |pattern| build_filter_string('working_patterns', pattern) }
                                                &.join(' OR ')
    @suitable_for_nqt_filter = build_filter_string('job_roles', 'nqt_suitable') if @suitable_for_nqt == 'true'
  end

  def build_date_filters
    return if @from_date.blank? && @to_date.blank?

    from_date_filter = "publication_date_timestamp >= #{@from_date.to_time.to_i}" if @from_date.present?
    to_date_filter = "publication_date_timestamp <= #{@to_date.to_time.to_i}" if @to_date.present?
    [from_date_filter, to_date_filter].reject(&:blank?).join(' AND ')
  end

  def build_filter_string(attribute, value)
    "#{attribute}:#{value}"
  end

  def published_today_filter
    Time.zone.today.to_time.to_i
  end

  def expired_now_filter
    Time.zone.now.to_time.to_i
  end
end
