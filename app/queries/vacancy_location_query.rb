class VacancyLocationQuery < LocationQuery
  def initialize(scope)
    @scope = scope
  end

  def call(...)
    super("vacancies.geolocation", ...)
  end
end
