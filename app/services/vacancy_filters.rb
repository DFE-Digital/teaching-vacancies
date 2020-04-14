class VacancyFilters
  include ActiveModel::Model

  AVAILABLE_FILTERS = %i[location radius keyword subject job_title working_patterns
                         phases newly_qualified_teacher].freeze

  attr_reader(*AVAILABLE_FILTERS)

  def initialize(args)
    args = ActiveSupport::HashWithIndifferentAccess.new(args)

    @location = args[:location]
    @radius = args[:radius].to_s if args[:radius].present? && !location_category_search?
    @keyword = args[:keyword]
    @subject = args[:subject]
    @job_title = args[:job_title]
    @newly_qualified_teacher = args[:newly_qualified_teacher]
    @working_patterns = extract_working_patterns(args[:working_patterns])
    @phases = extract_phases(args[:phases])
  end

  def to_hash
    {
      location: location,
      radius: radius,
      keyword: keyword,
      subject: subject,
      job_title: job_title,
      working_patterns: working_patterns,
      phases: phases,
      newly_qualified_teacher: newly_qualified_teacher,
    }
  end

  def audit_hash
    {
      location: location,
      radius: radius,
      keyword: keyword,
      working_patterns: working_patterns,
      phases: phases,
      newly_qualified_teacher: newly_qualified_teacher,
      subject: subject,
      job_title: job_title
    }
  end

  def only_active_to_hash
    to_hash.delete_if { |_, v| v.blank? }
  end

  def any?
    filters = only_active_to_hash
    filters.delete_if { |k, _| k.eql?(:radius) }
    filters.any?
  end

  def location_category_search?
    @location_category_search ||= (location && LocationCategory.include?(location))
  end

  private

  def extract_working_patterns(working_patterns)
    return if working_patterns.blank?

    working_patterns = JSON.parse(working_patterns) if working_patterns.is_a?(String)

    working_patterns.select { |working_pattern| Vacancy::WORKING_PATTERN_OPTIONS.include?(working_pattern) }.presence
  end

  def extract_phases(phases)
    return if phases.blank?

    phases = JSON.parse(phases) if phases.is_a?(String)

    phases.select { |phase| School.phases.include?(phase) }.presence
  end
end
