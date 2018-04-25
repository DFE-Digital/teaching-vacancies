class VacancyFilters
  attr_reader :location, :keyword, :minimum_salary, :maximum_salary, :working_pattern, :phase

  def initialize(args)
    args = ActiveSupport::HashWithIndifferentAccess.new(args)

    @location = args[:location]
    @keyword = args[:keyword]
    @minimum_salary = args[:minimum_salary]
    @maximum_salary = args[:maximum_salary]
    @working_pattern = extract_working_pattern(args)
    @phase = School.phases.include?(args[:phase]) ? args[:phase] : nil
  end

  private

  def extract_working_pattern(params)
    if Vacancy.working_patterns.include?(params[:working_pattern])
      return params[:working_pattern]
    end
    nil
  end
end
