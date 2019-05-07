class VacancyFilters
  AVAILABLE_FILTERS = %i[location radius subject job_title minimum_salary working_pattern
                         phases newly_qualified_teacher].freeze

  attr_reader(*AVAILABLE_FILTERS)

  def initialize(args)
    args = ActiveSupport::HashWithIndifferentAccess.new(args)

    @location = args[:location]
    @radius = args[:radius].to_s if args[:radius].present?
    @subject = args[:subject]
    @job_title = args[:job_title]
    @minimum_salary = args[:minimum_salary]
    @newly_qualified_teacher = args[:newly_qualified_teacher]
    @working_pattern = extract_working_pattern(args)
    @phases = extract_phases(args)
  end

  def to_hash
    {
      location: location,
      radius: radius,
      subject: subject,
      job_title: job_title,
      minimum_salary: minimum_salary,
      working_pattern: working_pattern,
      phases: phases,
      newly_qualified_teacher: newly_qualified_teacher,
    }
  end

  def audit_hash
    {
      location: location,
      radius: radius,
      keyword: nil,
      minimum_salary: minimum_salary,
      maximum_salary: nil,
      working_pattern: working_pattern,
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

  private

  def extract_working_pattern(params)
    params[:working_pattern] if Vacancy.working_patterns.include?(params[:working_pattern])
  end

  def extract_phases(params)
    return if params[:phases].blank?

    JSON.parse(params[:phases]).select { |phase| School.phases.include?(phase) }.presence
  end
end
