class VacancyFilters
  attr_reader :location, :radius, :keyword, :minimum_salary, :maximum_salary, :working_pattern, :phase,
              :newly_qualified_teacher

  def initialize(args)
    args = ActiveSupport::HashWithIndifferentAccess.new(args)

    @location = args[:location]
    @radius = args[:radius]
    @keyword = args[:keyword]
    @minimum_salary = args[:minimum_salary]
    @maximum_salary = args[:maximum_salary]
    @newly_qualified_teacher = args[:newly_qualified_teacher]
    @working_pattern = extract_working_pattern(args)
    @phase = School.phases.include?(args[:phase]) ? args[:phase] : nil
  end

  def to_hash
    {
      location: location,
      radius: "#{radius}km",
      keyword: keyword,
      minimum_salary: minimum_salary,
      maximum_salary: maximum_salary,
      working_pattern: working_pattern,
      phase: phase,
      newly_qualified_teacher: newly_qualified_teacher,
    }
  end

  private

  def extract_working_pattern(params)
    Vacancy.working_patterns.include?(params[:working_pattern]) ? params[:working_pattern] : nil
  end
end
