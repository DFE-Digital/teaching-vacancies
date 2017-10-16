class VacancyFilters
  attr_reader :location, :keyword, :minimum_salary, :maximum_salary, :working_pattern, :phase

  def initialize(params)
    @location = params[:location]
    @keyword = params[:keyword]
    @minimum_salary = params[:minimum_salary]
    @maximum_salary = params[:maximum_salary]
    @working_pattern = extract_working_pattern(params)
    @phase = School.phases.include?(params[:phase]) ? params[:phase] : nil
  end

  private

  def extract_working_pattern(params)
    if Vacancy.working_patterns.include?(params[:working_pattern])
      return params[:working_pattern]
    end
    nil
  end
end
